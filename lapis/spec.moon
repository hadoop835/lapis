
use_db_connection = ->
  import setup, teardown from require "busted"

  config = require("lapis.config").get!
  return unless config.postgres or config.mysql

  setup ->
    import connect from require "lapis.db"
    connect! if connect

use_test_env = (env_name="test") ->
  import setup, teardown from require "busted"
  env = require "lapis.environment"

  setup -> env.push env_name
  teardown -> env.pop!

  use_db_connection!

use_test_server = ->
  import setup, teardown from require "busted"
  import load_test_server, close_test_server from require "lapis.spec.server"

  setup -> load_test_server!
  teardown -> close_test_server!

  use_db_connection!

assert_no_queries = (fn=error"missing function") ->
  assert = require "luassert"
  db = require "lapis.db"

  old_query = db.get_raw_query!

  query_log = {}
  db.set_raw_query (...) ->
    table.insert query_log, (...)
    old_query ...

  res, err = pcall fn
  db.set_raw_query old_query
  assert res, err
  assert.same {}, query_log


-- used to determine if default environment should be test intead of development
-- should return the name of the test harness being used, otherwise false
running_in_test = ->
  busted = package.loaded.busted
  if busted and busted.publish
    return "busted"

  false

{:use_test_env, :use_test_server, :assert_no_queries, :running_in_test}
