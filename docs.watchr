# Run me with:
#   $ watchr docs.watchr

require 'yard'
# --------------------------------------------------
# Watchr Rules
# --------------------------------------------------
watch( 'lib/.*\.rb'  ) { yard }
watch( 'README.md'   ) { yard }
watch( 'LICENSE'     ) { yard }

# --------------------------------------------------
# Signal Handling
# --------------------------------------------------
Signal.trap('QUIT') { yard        } # Ctrl-\
Signal.trap('INT' ) { abort("\n") } # Ctrl-C

# --------------------------------------------------
# Helpers
# --------------------------------------------------
def yard
  print "Updating yardocs... "; STDOUT.flush
  YARD::CLI::Yardoc.run *%w( -o doc/yard --readme README.md --markup rdoc - LICENSE )
  print "done\n"
end

