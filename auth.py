
import getpass
import httplib
import urllib
import urlparse
import re
from optparse import OptionParser
import sys
import logging
import time
import atexit
import socket
import gc
import netrc

class FirewallState:
  Start, LoggedIn, End = range(3)

username = None
password = None

def start_func():
  """
  This is called when we're in the initial state. If we're already logged in, we
  can't do anything much. If we're not, we should transition to the
  not-logged-in state.
  """
  ERROR_RETRY_SECS = 5
  LOGGED_IN_RETRY_SECS = 5
  logger = logging.getLogger("FirewallLogger")

  try:
    loginstate, data = login()
  except (httplib.HTTPException, socket.error) as e:
    logger.info("Exception |%s| while trying to log in. Retrying in %d seconds." %
                (e, ERROR_RETRY_SECS))
    return (FirewallState.Start, ERROR_RETRY_SECS, None)

  if loginstate == LoginState.AlreadyLoggedIn:
    logger.info("You're already logged in (response code %d). Retrying in %d seconds." %
                (data, LOGGED_IN_RETRY_SECS))
    return (FirewallState.Start, LOGGED_IN_RETRY_SECS, None)
  elif loginstate == LoginState.InvalidCredentials:
    return (FirewallState.End, 0, [3])
  else:
    return (FirewallState.LoggedIn, 0, [data])

def logged_in_func(keepaliveurl):
  """
  Keep the firewall authentication alive by pinging a keepalive URL every few
  seconds. If there are any connection problems, keep trying with the same
  URL. If the keepalive URL doesn't work any more, go back to the start state.
  """
  logger = logging.getLogger("FirewallLogger")
  ERROR_RETRY_SECS = 5
  LOGGED_IN_SECS = 200
  try:
    keep_alive(keepaliveurl)
  except httplib.BadStatusLine:
    logger.info("The keepalive URL %s doesn't work. Attempting to log in again." %
                keepaliveurl.geturl())
    return (FirewallState.Start, 0, None)
  except (httplib.HTTPException, socket.error) as e:
    logger.info("Exception |%s| while trying to keep alive. Retrying in %d seconds." %
                (e, ERROR_RETRY_SECS))
    return (FirewallState.LoggedIn, ERROR_RETRY_SECS, [keepaliveurl])

  return (FirewallState.LoggedIn, LOGGED_IN_SECS, [keepaliveurl])

state_functions = {
  FirewallState.Start: start_func,
  FirewallState.LoggedIn: logged_in_func,
  FirewallState.End: sys.exit
}

def run_state_machine():
  """
  Runs the state machine defined above.
  """
  state = FirewallState.Start
  args = None
  sleeptime = 0
  def atexit_logout():
    """
    Log out from firewall authentication. This is supposed to run whenever the
    program exits.
    """
    logger = logging.getLogger("FirewallLogger")
    if state == FirewallState.LoggedIn:
      url = args[0]
      logouturl = urlparse.ParseResult(url.scheme, url.netloc, "/logout",
                                       url.params, url.query, url.fragment)
      try:
        logger.info("Logging out with URL %s" % logouturl.geturl())
        conn = httplib.HTTPSConnection(logouturl.netloc)
        conn.request("GET", logouturl.path + "?" + logouturl.query)
        response = conn.getresponse()
        response.read()
      except (httplib.HTTPException, socket.error) as e:
        logger.info("Exception |%s| while logging out." % e)
      finally:
        conn.close()

  atexit.register(atexit_logout)

  while True:
    statefunc = state_functions[state]
    if args is None:
      state, sleeptime, args = statefunc()
    else:
      state, sleeptime, args = statefunc(*args)
    if sleeptime > 0:
      time.sleep(sleeptime)

class LoginState:
  AlreadyLoggedIn, InvalidCredentials, Successful = range(3)

def login():
  """
  Attempt to log in. Returns AlreadyLoggedIn if we're already logged in,
  InvalidCredentials if the username and password given are incorrect, and
  Successful if we have managed to log in. Throws an exception if an error
  occurs somewhere along the process.
  """
  logger = logging.getLogger("FirewallLogger")
  try:
    conn = httplib.HTTPConnection("74.125.236.51:80")
    conn.request("GET", "/")
    response = conn.getresponse()
    if (response.status != 303):
      return (LoginState.AlreadyLoggedIn, response.status)

    authlocation = response.getheader("Location")
  finally:
    conn.close()

  logger.info("The auth location is: %s" % authlocation)

  parsedauthloc = urlparse.urlparse(authlocation)
  try:
    authconn = httplib.HTTPSConnection(parsedauthloc.netloc)
    authconn.request("GET", parsedauthloc.path + "?" + parsedauthloc.query)
    authResponse = authconn.getresponse()
    data = authResponse.read()
  finally:
    authconn.close()

  match = re.search(r"VALUE=\"([0-9a-f]+)\"", data, re.IGNORECASE)
  magicString = match.group(1)
  logger.debug("The magic string is: " + magicString)

  params = urllib.urlencode({'username': username, 'password': password,
                             'magic': magicString, '4Tredir': '/'})
  headers = {"Content-Type": "application/x-www-form-urlencoded",
             "Accept": "text/plain"}

  try:
    postconn = httplib.HTTPSConnection(parsedauthloc.netloc)
    postconn.request("POST", "/", params, headers)

    postResponse = postconn.getresponse()
    postData = postResponse.read()
  finally:
    postconn.close()

  keepaliveMatch = re.search(r"location.href=\"(.+?)\"", postData)
  if keepaliveMatch is None:
    logger.fatal("Authentication unsuccessful, check your username and password.")
    return (LoginState.InvalidCredentials, None)

  keepaliveURL = keepaliveMatch.group(1)

  logger.info("The keep alive URL is: " + keepaliveURL)
  logger.debug(postData)
  return (LoginState.Successful, urlparse.urlparse(keepaliveURL))

def keep_alive(url):
  """
  Attempt to keep the connection alive by pinging a URL.
  """
  logger = logging.getLogger("FirewallLogger")
  logger.info("Sending request to keep alive.")
  try:
    conn = httplib.HTTPSConnection(url.netloc)
    conn.request("GET", url.path + "?" + url.query)
    response = conn.getresponse()

    logger.debug(str(response.status))
    logger.debug(response.read())
  finally:
    conn.close()
    gc.collect()

def get_credentials(options, args):
  """
  Get the username and password, from netrc, command line args or interactively.
  """
  username = None
  password = None

  if options.netrc:
    logger = logging.getLogger("FirewallLogger")
    try:
      info = netrc.netrc()
      cred = info.authenticators("172.31.1.251")
      if cred:
        return (cred[0], cred[2])
      logger.info("Could not find credentials in netrc file.")
    except:
      logger.info("Could not read from netrc file.")

  if len(args) == 0:
    print "Username: ",
    username = sys.stdin.readline()[:-1]
  else:
    username = args[0]

  if len(args) <= 1:
    password = getpass.getpass()
  else:
    password = args[1]

  return (username, password)

def init_logger(options):
  logger = logging.getLogger("FirewallLogger")
  logger.setLevel(logging.DEBUG)
  handler = logging.StreamHandler()
  if options.verbose:
    handler.setLevel(logging.DEBUG)
  else:
    handler.setLevel(logging.INFO)

  formatter = logging.Formatter("%(asctime)s - %(levelname)s - %(message)s")
  handler.setFormatter(formatter)
  logger.addHandler(handler)

"""
Main function
"""
def main(argv = None):
  if argv is None:
    argv = sys.argv[1:]

  usage = "Usage: %prog [options] [username [password]]"
  parser = OptionParser(usage = usage)
  parser.add_option("-v", "--verbose", action = "store_true", dest = "verbose",
                    help = "Print lots of debugging information")
  parser.add_option("-n", "--netrc", action = "store_true", dest = "netrc",
                    help = "Read credentials from netrc file")

  (options, args) = parser.parse_args(argv)

  if len(args) > 2:
    parser.error("too many arguments")
    return 1

  init_logger(options)

  global username, password
  username, password = get_credentials(options, args)
  run_state_machine()
  return 0

if __name__ == "__main__":
  sys.exit(main())
