# Print an optspec for argparse to handle cmd's options that are independent of any subcommand.
function __fish_cass_global_optspecs
	string join \n db= robot-help trace-file= q/quiet v/verbose color= progress= wrap= nowrap h/help V/version
end

function __fish_cass_needs_command
	# Figure out if the current invocation already has a command.
	set -l cmd (commandline -opc)
	set -e cmd[1]
	argparse -s (__fish_cass_global_optspecs) -- $cmd 2>/dev/null
	or return
	if set -q argv[1]
		# Also print the command, so this can be used to figure out what it is.
		echo $argv[1]
		return 1
	end
	return 0
end

function __fish_cass_using_subcommand
	set -l cmd (__fish_cass_needs_command)
	test -z "$cmd"
	and return 1
	contains -- $cmd[1] $argv
end

complete -c cass -n "__fish_cass_needs_command" -l db -d 'Path to the `SQLite` database (defaults to platform data dir)' -r -F
complete -c cass -n "__fish_cass_needs_command" -l trace-file -d 'Trace command execution to JSONL file (spans)' -r -F
complete -c cass -n "__fish_cass_needs_command" -l color -d 'Color behavior for CLI output' -r -f -a "auto\t''
never\t''
always\t''"
complete -c cass -n "__fish_cass_needs_command" -l progress -d 'Progress output style' -r -f -a "auto\t''
bars\t''
plain\t''
none\t''"
complete -c cass -n "__fish_cass_needs_command" -l wrap -d 'Wrap informational output to N columns' -r
complete -c cass -n "__fish_cass_needs_command" -l robot-help -d 'Deterministic machine-first help (wide, no TUI)'
complete -c cass -n "__fish_cass_needs_command" -s q -l quiet -d 'Reduce log noise (warnings and errors only)'
complete -c cass -n "__fish_cass_needs_command" -s v -l verbose -d 'Increase verbosity (show debug information)'
complete -c cass -n "__fish_cass_needs_command" -l nowrap -d 'Disable wrapping entirely'
complete -c cass -n "__fish_cass_needs_command" -s h -l help -d 'Print help'
complete -c cass -n "__fish_cass_needs_command" -s V -l version -d 'Print version'
complete -c cass -n "__fish_cass_needs_command" -f -a "tui" -d 'Launch interactive TUI'
complete -c cass -n "__fish_cass_needs_command" -f -a "index" -d 'Run indexer'
complete -c cass -n "__fish_cass_needs_command" -f -a "completions" -d 'Generate shell completions to stdout'
complete -c cass -n "__fish_cass_needs_command" -f -a "man" -d 'Generate man page to stdout'
complete -c cass -n "__fish_cass_needs_command" -f -a "robot-docs" -d 'Machine-focused docs for automation agents'
complete -c cass -n "__fish_cass_needs_command" -f -a "search" -d 'Run a one-off search and print results to stdout'
complete -c cass -n "__fish_cass_needs_command" -f -a "stats" -d 'Show statistics about indexed data'
complete -c cass -n "__fish_cass_needs_command" -f -a "diag" -d 'Output diagnostic information for troubleshooting'
complete -c cass -n "__fish_cass_needs_command" -f -a "status" -d 'Quick health check for agents: index freshness, db stats, recommended action'
complete -c cass -n "__fish_cass_needs_command" -f -a "capabilities" -d 'Discover available features, versions, and limits for agent introspection'
complete -c cass -n "__fish_cass_needs_command" -f -a "state" -d 'Quick state/health check (alias of status)'
complete -c cass -n "__fish_cass_needs_command" -f -a "api-version" -d 'Show API + contract version info'
complete -c cass -n "__fish_cass_needs_command" -f -a "introspect" -d 'Full API schema introspection - commands, arguments, and response schemas'
complete -c cass -n "__fish_cass_needs_command" -f -a "view" -d 'View a source file at a specific line (follow up on search results)'
complete -c cass -n "__fish_cass_needs_command" -f -a "health" -d 'Minimal health check (<50ms). Exit 0=healthy, 1=unhealthy. For agent pre-flight checks'
complete -c cass -n "__fish_cass_needs_command" -f -a "doctor" -d 'Diagnose and repair cass installation issues. Safe by default - never deletes user data. Use --fix to apply automatic repairs (rebuilds derived data only, preserves source sessions)'
complete -c cass -n "__fish_cass_needs_command" -f -a "context" -d 'Find related sessions for a given source path'
complete -c cass -n "__fish_cass_needs_command" -f -a "export" -d 'Export a conversation to markdown or other formats'
complete -c cass -n "__fish_cass_needs_command" -f -a "export-html" -d 'Export session as beautiful, self-contained HTML (with optional encryption)'
complete -c cass -n "__fish_cass_needs_command" -f -a "expand" -d 'Show messages around a specific line in a session file'
complete -c cass -n "__fish_cass_needs_command" -f -a "timeline" -d 'Show activity timeline for a time range'
complete -c cass -n "__fish_cass_needs_command" -f -a "pages" -d 'Export encrypted searchable archive for static hosting (P4.x)'
complete -c cass -n "__fish_cass_needs_command" -f -a "sources" -d 'Manage remote sources (P5.x)'
complete -c cass -n "__fish_cass_needs_command" -f -a "models" -d 'Manage semantic search models'
complete -c cass -n "__fish_cass_needs_command" -f -a "import" -d 'Import data from external sources'
complete -c cass -n "__fish_cass_needs_command" -f -a "help" -d 'Print this message or the help of the given subcommand(s)'
complete -c cass -n "__fish_cass_using_subcommand tui" -l data-dir -d 'Override data dir (matches index --data-dir)' -r -F
complete -c cass -n "__fish_cass_using_subcommand tui" -l once -d 'Render once and exit (headless-friendly)'
complete -c cass -n "__fish_cass_using_subcommand tui" -l reset-state -d 'Delete persisted UI state (`tui_state.json`) before launch'
complete -c cass -n "__fish_cass_using_subcommand tui" -s h -l help -d 'Print help'
complete -c cass -n "__fish_cass_using_subcommand index" -l watch-once -d 'Trigger a single watch cycle for specific paths (comma-separated or repeated)' -r -F
complete -c cass -n "__fish_cass_using_subcommand index" -l embedder -d 'Embedder to use for semantic indexing (hash, fastembed)' -r
complete -c cass -n "__fish_cass_using_subcommand index" -l data-dir -d 'Override data dir (index + db). Defaults to platform data dir' -r -F
complete -c cass -n "__fish_cass_using_subcommand index" -l idempotency-key -d 'Idempotency key for safe retries. If the same key is used with identical parameters, the cached result is returned. Keys expire after 24 hours' -r
complete -c cass -n "__fish_cass_using_subcommand index" -l full -d 'Perform full rebuild'
complete -c cass -n "__fish_cass_using_subcommand index" -l force-rebuild -l force -d 'Force Tantivy index rebuild even if schema matches'
complete -c cass -n "__fish_cass_using_subcommand index" -l watch -d 'Watch for changes and reindex automatically'
complete -c cass -n "__fish_cass_using_subcommand index" -l semantic -d 'Build semantic vector index after text indexing'
complete -c cass -n "__fish_cass_using_subcommand index" -l build-hnsw -d 'Build HNSW index for approximate nearest neighbor search (requires --semantic). Enables O(log n) search with `--approximate` flag at query time'
complete -c cass -n "__fish_cass_using_subcommand index" -l json -l robot -d 'Output as JSON (for automation)'
complete -c cass -n "__fish_cass_using_subcommand index" -s h -l help -d 'Print help'
complete -c cass -n "__fish_cass_using_subcommand completions" -s h -l help -d 'Print help'
complete -c cass -n "__fish_cass_using_subcommand man" -s h -l help -d 'Print help'
complete -c cass -n "__fish_cass_using_subcommand robot-docs" -s h -l help -d 'Print help'
complete -c cass -n "__fish_cass_using_subcommand search" -l agent -d 'Filter by agent slug (can be specified multiple times)' -r
complete -c cass -n "__fish_cass_using_subcommand search" -l workspace -d 'Filter by workspace path (can be specified multiple times)' -r
complete -c cass -n "__fish_cass_using_subcommand search" -l limit -d 'Max results' -r
complete -c cass -n "__fish_cass_using_subcommand search" -l offset -d 'Offset for pagination (start at Nth result)' -r
complete -c cass -n "__fish_cass_using_subcommand search" -l robot-format -d 'Robot output format: json (pretty), jsonl (streaming), compact (single-line), sessions (paths), toon (token-optimized). Env: CASS_OUTPUT_FORMAT, TOON_DEFAULT_FORMAT' -r -f -a "json\t'Pretty-printed JSON object (default, backward compatible)'
jsonl\t'Newline-delimited JSON: one object per line with optional _meta header'
compact\t'Compact single-line JSON (no pretty printing)'
sessions\t'Session paths only: one source_path per line (for chained searches)'
toon\t'Token-Optimized Object Notation (encodes via toon_rust crate)'"
complete -c cass -n "__fish_cass_using_subcommand search" -l fields -d 'Select specific fields in JSON output (comma-separated). Use \'minimal\' for `source_path,line_number,agent` or \'summary\' for `source_path,line_number,agent,title,score`. Example: --fields `source_path,line_number`' -r
complete -c cass -n "__fish_cass_using_subcommand search" -l max-content-length -d 'Truncate content/snippet fields to max N characters (UTF-8 safe, adds \'...\' and _truncated indicator)' -r
complete -c cass -n "__fish_cass_using_subcommand search" -l max-tokens -d 'Soft token budget for robot output (approx; 4 chars ≈ 1 token). Adjusts truncation' -r
complete -c cass -n "__fish_cass_using_subcommand search" -l request-id -d 'Request ID to echo in robot _meta for correlation' -r
complete -c cass -n "__fish_cass_using_subcommand search" -l cursor -d 'Cursor for pagination (base64-encoded offset/limit payload from previous result)' -r
complete -c cass -n "__fish_cass_using_subcommand search" -l display -d 'Human-readable display format: table (aligned columns), lines (one-liner), markdown' -r -f -a "table\t'Aligned columns with headers (default human-readable)'
lines\t'One-liner per result with key info'
markdown\t'Markdown with role headers and code blocks'"
complete -c cass -n "__fish_cass_using_subcommand search" -l data-dir -d 'Override data dir' -r -F
complete -c cass -n "__fish_cass_using_subcommand search" -l days -d 'Filter to last N days' -r
complete -c cass -n "__fish_cass_using_subcommand search" -l since -d 'Filter to entries since ISO date (YYYY-MM-DD or YYYY-MM-DDTHH:MM:SS)' -r
complete -c cass -n "__fish_cass_using_subcommand search" -l until -d 'Filter to entries until ISO date' -r
complete -c cass -n "__fish_cass_using_subcommand search" -l aggregate -d 'Server-side aggregation by field(s). Comma-separated: `agent,workspace,date,match_type` Returns buckets with counts instead of full results. Use with --limit to get both' -r
complete -c cass -n "__fish_cass_using_subcommand search" -l timeout -d 'Timeout in milliseconds. Returns partial results and error if exceeded' -r
complete -c cass -n "__fish_cass_using_subcommand search" -l source -d 'Filter by source: \'local\', \'remote\', \'all\', or a specific source hostname' -r
complete -c cass -n "__fish_cass_using_subcommand search" -l sessions-from -d 'Filter to sessions from file (one path per line). Use \'-\' for stdin. Enables chained searches: `cass search "query1" --robot-format sessions | cass search "query2" --sessions-from -`' -r
complete -c cass -n "__fish_cass_using_subcommand search" -l mode -d 'Search mode: lexical (default), semantic, or hybrid' -r -f -a "lexical\t'Lexical (BM25) search - keyword matching'
semantic\t'Semantic search - embedding similarity'
hybrid\t'Hybrid search - RRF fusion of lexical and semantic'"
complete -c cass -n "__fish_cass_using_subcommand search" -l model -d 'Embedding model to use for semantic search. Available models depend on what\'s been downloaded. Use `cass models --list` to see available options' -r
complete -c cass -n "__fish_cass_using_subcommand search" -l reranker -d 'Reranker model to use (requires --rerank). Use `cass models --list` to see available options' -r
complete -c cass -n "__fish_cass_using_subcommand search" -l json -l robot -d 'Output as JSON (--robot also works). Equivalent to --robot-format json'
complete -c cass -n "__fish_cass_using_subcommand search" -l robot-meta -d 'Include extended metadata in robot output (`elapsed_ms`, `wildcard_fallback`, `cache_stats`)'
complete -c cass -n "__fish_cass_using_subcommand search" -l today -d 'Filter to today only'
complete -c cass -n "__fish_cass_using_subcommand search" -l yesterday -d 'Filter to yesterday only'
complete -c cass -n "__fish_cass_using_subcommand search" -l week -d 'Filter to last 7 days'
complete -c cass -n "__fish_cass_using_subcommand search" -l explain -d 'Include query explanation in output (shows parsed query, index strategy, cost estimate)'
complete -c cass -n "__fish_cass_using_subcommand search" -l dry-run -d 'Validate and analyze query without executing (returns explanation, estimated cost, warnings)'
complete -c cass -n "__fish_cass_using_subcommand search" -l highlight -d 'Highlight matching terms in output (uses **bold** markers in text, <mark> in HTML)'
complete -c cass -n "__fish_cass_using_subcommand search" -l approximate -d 'Use approximate nearest neighbor (ANN) search with HNSW for faster semantic/hybrid queries. Trades slight accuracy loss for O(log n) search complexity instead of O(n). Only affects semantic and hybrid modes; ignored for lexical search. Requires an HNSW index built with `cass index --semantic --approximate`'
complete -c cass -n "__fish_cass_using_subcommand search" -l rerank -d 'Enable reranking of search results for improved relevance. Requires a reranker model to be available'
complete -c cass -n "__fish_cass_using_subcommand search" -l daemon -d 'Use daemon for warm model inference (faster repeated queries). If daemon is unavailable, falls back to direct inference'
complete -c cass -n "__fish_cass_using_subcommand search" -l no-daemon -d 'Disable daemon usage even if available (force direct inference)'
complete -c cass -n "__fish_cass_using_subcommand search" -l two-tier -d 'Enable two-tier progressive search: fast results immediately, refined via daemon. Returns initial results from fast embedder (~1ms), then refines with quality embedder via daemon (~130ms). Best of both worlds for interactive search'
complete -c cass -n "__fish_cass_using_subcommand search" -l fast-only -d 'Fast-only search: use lightweight embedder for instant results, no refinement. Ideal for real-time search-as-you-type scenarios where latency is critical'
complete -c cass -n "__fish_cass_using_subcommand search" -l quality-only -d 'Quality-only search: wait for full transformer model results. Higher latency (~130ms) but most accurate semantic matching. Requires daemon to be available; falls back to fast if unavailable'
complete -c cass -n "__fish_cass_using_subcommand search" -s h -l help -d 'Print help (see more with \'--help\')'
complete -c cass -n "__fish_cass_using_subcommand stats" -l data-dir -d 'Override data dir' -r -F
complete -c cass -n "__fish_cass_using_subcommand stats" -l source -d 'Filter by source: \'local\', \'remote\', \'all\', or a specific source hostname' -r
complete -c cass -n "__fish_cass_using_subcommand stats" -l json -l robot -d 'Output as JSON'
complete -c cass -n "__fish_cass_using_subcommand stats" -l by-source -d 'Show breakdown by source'
complete -c cass -n "__fish_cass_using_subcommand stats" -s h -l help -d 'Print help'
complete -c cass -n "__fish_cass_using_subcommand diag" -l data-dir -d 'Override data dir' -r -F
complete -c cass -n "__fish_cass_using_subcommand diag" -l json -l robot -d 'Output as JSON'
complete -c cass -n "__fish_cass_using_subcommand diag" -s v -l verbose -d 'Include verbose information (file sizes, timestamps)'
complete -c cass -n "__fish_cass_using_subcommand diag" -s h -l help -d 'Print help'
complete -c cass -n "__fish_cass_using_subcommand status" -l data-dir -d 'Override data dir' -r -F
complete -c cass -n "__fish_cass_using_subcommand status" -l stale-threshold -d 'Staleness threshold in seconds (default: 1800 = 30 minutes)' -r
complete -c cass -n "__fish_cass_using_subcommand status" -l json -l robot -d 'Output as JSON (default for robot consumption)'
complete -c cass -n "__fish_cass_using_subcommand status" -l robot-meta -d 'Include _meta block (elapsed, freshness, data_dir/db_path)'
complete -c cass -n "__fish_cass_using_subcommand status" -s h -l help -d 'Print help'
complete -c cass -n "__fish_cass_using_subcommand capabilities" -l json -l robot -d 'Output as JSON (default for robot consumption)'
complete -c cass -n "__fish_cass_using_subcommand capabilities" -s h -l help -d 'Print help'
complete -c cass -n "__fish_cass_using_subcommand state" -l data-dir -d 'Override data dir' -r -F
complete -c cass -n "__fish_cass_using_subcommand state" -l stale-threshold -d 'Staleness threshold in seconds (default: 1800 = 30 minutes)' -r
complete -c cass -n "__fish_cass_using_subcommand state" -l json -l robot -d 'Output as JSON (default for robot consumption)'
complete -c cass -n "__fish_cass_using_subcommand state" -l robot-meta -d 'Include _meta block (elapsed, freshness, data_dir/db_path)'
complete -c cass -n "__fish_cass_using_subcommand state" -s h -l help -d 'Print help'
complete -c cass -n "__fish_cass_using_subcommand api-version" -l json -l robot -d 'Output as JSON (default for robot consumption)'
complete -c cass -n "__fish_cass_using_subcommand api-version" -s h -l help -d 'Print help'
complete -c cass -n "__fish_cass_using_subcommand introspect" -l json -l robot -d 'Output as JSON (default for robot consumption)'
complete -c cass -n "__fish_cass_using_subcommand introspect" -s h -l help -d 'Print help'
complete -c cass -n "__fish_cass_using_subcommand view" -s n -l line -d 'Line number to show (1-indexed)' -r
complete -c cass -n "__fish_cass_using_subcommand view" -s C -l context -d 'Number of context lines before/after' -r
complete -c cass -n "__fish_cass_using_subcommand view" -l json -l robot -d 'Output as JSON'
complete -c cass -n "__fish_cass_using_subcommand view" -s h -l help -d 'Print help'
complete -c cass -n "__fish_cass_using_subcommand health" -l data-dir -d 'Override data dir' -r -F
complete -c cass -n "__fish_cass_using_subcommand health" -l stale-threshold -d 'Staleness threshold in seconds (default: 300)' -r
complete -c cass -n "__fish_cass_using_subcommand health" -l json -l robot -d 'Output as JSON (`{"healthy": bool, "latency_ms": N}`)'
complete -c cass -n "__fish_cass_using_subcommand health" -l robot-meta -d 'Include _meta block (elapsed, freshness, data_dir/db_path)'
complete -c cass -n "__fish_cass_using_subcommand health" -s h -l help -d 'Print help'
complete -c cass -n "__fish_cass_using_subcommand doctor" -l data-dir -d 'Override data dir' -r -F
complete -c cass -n "__fish_cass_using_subcommand doctor" -l json -l robot -d 'Output as JSON'
complete -c cass -n "__fish_cass_using_subcommand doctor" -l fix -d 'Apply safe fixes automatically (rebuilds index/db from source data)'
complete -c cass -n "__fish_cass_using_subcommand doctor" -s v -l verbose -d 'Run all checks verbosely (show passed checks too)'
complete -c cass -n "__fish_cass_using_subcommand doctor" -l force-rebuild -l force -d 'Force index rebuild even if index appears healthy'
complete -c cass -n "__fish_cass_using_subcommand doctor" -s h -l help -d 'Print help'
complete -c cass -n "__fish_cass_using_subcommand context" -l data-dir -d 'Override data dir' -r -F
complete -c cass -n "__fish_cass_using_subcommand context" -l limit -d 'Maximum results per relation type (default: 5)' -r
complete -c cass -n "__fish_cass_using_subcommand context" -l json -l robot -d 'Output as JSON'
complete -c cass -n "__fish_cass_using_subcommand context" -s h -l help -d 'Print help'
complete -c cass -n "__fish_cass_using_subcommand export" -l format -d 'Output format' -r -f -a "markdown\t'Markdown with headers and formatting'
text\t'Plain text'
json\t'JSON array of messages'
html\t'HTML with styling'"
complete -c cass -n "__fish_cass_using_subcommand export" -s o -l output -d 'Output file (stdout if not specified)' -r -F
complete -c cass -n "__fish_cass_using_subcommand export" -l include-tools -d 'Include tool use details in export'
complete -c cass -n "__fish_cass_using_subcommand export" -s h -l help -d 'Print help (see more with \'--help\')'
complete -c cass -n "__fish_cass_using_subcommand export-html" -l output-dir -d 'Output directory (default: current directory)' -r -F
complete -c cass -n "__fish_cass_using_subcommand export-html" -l filename -d 'Custom filename (default: auto-generated from session metadata)' -r
complete -c cass -n "__fish_cass_using_subcommand export-html" -l password -d 'Password for encryption (required if --encrypt)' -r
complete -c cass -n "__fish_cass_using_subcommand export-html" -l theme -d 'Default theme (dark or light)' -r
complete -c cass -n "__fish_cass_using_subcommand export-html" -l encrypt -d 'Enable password encryption (Web Crypto compatible)'
complete -c cass -n "__fish_cass_using_subcommand export-html" -l password-stdin -d 'Read password from stdin (secure, no echo)'
complete -c cass -n "__fish_cass_using_subcommand export-html" -l include-tools -d 'Include tool calls in export (default: true)'
complete -c cass -n "__fish_cass_using_subcommand export-html" -l show-timestamps -d 'Show message timestamps'
complete -c cass -n "__fish_cass_using_subcommand export-html" -l no-cdns -d 'Disable CDN references (fully offline, larger file)'
complete -c cass -n "__fish_cass_using_subcommand export-html" -l dry-run -d 'Validate without writing file'
complete -c cass -n "__fish_cass_using_subcommand export-html" -l explain -d 'Show export plan without executing'
complete -c cass -n "__fish_cass_using_subcommand export-html" -l open -d 'Open file in browser after export'
complete -c cass -n "__fish_cass_using_subcommand export-html" -l json -l robot -d 'JSON output (for automation)'
complete -c cass -n "__fish_cass_using_subcommand export-html" -s h -l help -d 'Print help'
complete -c cass -n "__fish_cass_using_subcommand expand" -s n -l line -d 'Line number to show context around' -r
complete -c cass -n "__fish_cass_using_subcommand expand" -s C -l context -d 'Number of messages before/after (default: 3)' -r
complete -c cass -n "__fish_cass_using_subcommand expand" -l json -l robot -d 'Output as JSON'
complete -c cass -n "__fish_cass_using_subcommand expand" -s h -l help -d 'Print help'
complete -c cass -n "__fish_cass_using_subcommand timeline" -l since -d 'Start time (ISO date, \'today\', \'yesterday\', \'Nd\' for N days ago)' -r
complete -c cass -n "__fish_cass_using_subcommand timeline" -l until -d 'End time (ISO date or relative)' -r
complete -c cass -n "__fish_cass_using_subcommand timeline" -l agent -d 'Filter by agent (can be repeated)' -r
complete -c cass -n "__fish_cass_using_subcommand timeline" -l data-dir -d 'Override data dir' -r -F
complete -c cass -n "__fish_cass_using_subcommand timeline" -l group-by -d 'Group by: hour, day, or none' -r -f -a "hour\t'Group by hour'
day\t'Group by day'
none\t'No grouping (flat list)'"
complete -c cass -n "__fish_cass_using_subcommand timeline" -l source -d 'Filter by source: \'local\', \'remote\', \'all\', or a specific source hostname' -r
complete -c cass -n "__fish_cass_using_subcommand timeline" -l today -d 'Show today only'
complete -c cass -n "__fish_cass_using_subcommand timeline" -l json -l robot -d 'Output as JSON'
complete -c cass -n "__fish_cass_using_subcommand timeline" -s h -l help -d 'Print help (see more with \'--help\')'
complete -c cass -n "__fish_cass_using_subcommand pages" -l export-only -d 'Export only (skip wizard and encryption) to specified directory' -r -F
complete -c cass -n "__fish_cass_using_subcommand pages" -l verify -d 'Verify an existing export bundle (for CI/CD)' -r -F
complete -c cass -n "__fish_cass_using_subcommand pages" -l agents -d 'Filter by agent (comma-separated)' -r
complete -c cass -n "__fish_cass_using_subcommand pages" -l workspaces -d 'Filter by workspace (comma-separated)' -r
complete -c cass -n "__fish_cass_using_subcommand pages" -l since -d 'Filter entries since ISO date or relative time' -r
complete -c cass -n "__fish_cass_using_subcommand pages" -l until -d 'Filter entries until ISO date or relative time' -r
complete -c cass -n "__fish_cass_using_subcommand pages" -l path-mode -d 'Path mode: relative (default), basename, full, hash' -r -f -a "relative\t''
basename\t''
full\t''
hash\t''"
complete -c cass -n "__fish_cass_using_subcommand pages" -l target -d 'Deployment target: local, github, cloudflare' -r -f -a "local\t'Local export only'
github\t'GitHub Pages deployment'
cloudflare\t'Cloudflare Pages deployment'"
complete -c cass -n "__fish_cass_using_subcommand pages" -l project -d 'Cloudflare project name (also used for GitHub repo name)' -r
complete -c cass -n "__fish_cass_using_subcommand pages" -l branch -d 'Cloudflare production branch (default: main)' -r
complete -c cass -n "__fish_cass_using_subcommand pages" -l account-id -d 'Cloudflare account ID (or CLOUDFLARE_ACCOUNT_ID env)' -r
complete -c cass -n "__fish_cass_using_subcommand pages" -l api-token -d 'Cloudflare API token (or CLOUDFLARE_API_TOKEN env)' -r
complete -c cass -n "__fish_cass_using_subcommand pages" -l secrets-allow -d 'Allowlist regex patterns to suppress findings (repeatable or comma-separated)' -r
complete -c cass -n "__fish_cass_using_subcommand pages" -l secrets-deny -d 'Denylist regex patterns to force findings (repeatable or comma-separated)' -r
complete -c cass -n "__fish_cass_using_subcommand pages" -l preview -d 'Preview an existing export locally (starts HTTP server)' -r -F
complete -c cass -n "__fish_cass_using_subcommand pages" -l port -d 'Port for preview server (default: 8080)' -r
complete -c cass -n "__fish_cass_using_subcommand pages" -l config -d 'JSON config file for non-interactive export (use "-" for stdin)' -r
complete -c cass -n "__fish_cass_using_subcommand pages" -l dry-run -d 'Dry run (don\'t write files)'
complete -c cass -n "__fish_cass_using_subcommand pages" -l scan-secrets -d 'Scan for secrets and exit (no export)'
complete -c cass -n "__fish_cass_using_subcommand pages" -l fail-on-secrets -d 'Fail with non-zero exit if secrets are detected (for CI)'
complete -c cass -n "__fish_cass_using_subcommand pages" -l json -l robot -d 'Output results as JSON (for verify and secret scan)'
complete -c cass -n "__fish_cass_using_subcommand pages" -s v -l verbose -d 'Verbose output (show detailed check results)'
complete -c cass -n "__fish_cass_using_subcommand pages" -l no-encryption -d 'Export without encryption (DANGEROUS - all content publicly readable)'
complete -c cass -n "__fish_cass_using_subcommand pages" -l i-understand-unencrypted-risks -d 'Acknowledge unencrypted export risks (required in robot/JSON mode with --no-encryption)'
complete -c cass -n "__fish_cass_using_subcommand pages" -l include-attachments -d 'Include message attachments (images, PDFs, code snapshots)'
complete -c cass -n "__fish_cass_using_subcommand pages" -l no-open -d 'Don\'t auto-open browser when starting preview server'
complete -c cass -n "__fish_cass_using_subcommand pages" -l validate-config -d 'Validate config file without running export'
complete -c cass -n "__fish_cass_using_subcommand pages" -l example-config -d 'Show example config file'
complete -c cass -n "__fish_cass_using_subcommand pages" -s h -l help -d 'Print help (see more with \'--help\')'
complete -c cass -n "__fish_cass_using_subcommand sources; and not __fish_seen_subcommand_from list add remove doctor sync mappings discover setup help" -s h -l help -d 'Print help'
complete -c cass -n "__fish_cass_using_subcommand sources; and not __fish_seen_subcommand_from list add remove doctor sync mappings discover setup help" -f -a "list" -d 'List configured sources'
complete -c cass -n "__fish_cass_using_subcommand sources; and not __fish_seen_subcommand_from list add remove doctor sync mappings discover setup help" -f -a "add" -d 'Add a new remote source'
complete -c cass -n "__fish_cass_using_subcommand sources; and not __fish_seen_subcommand_from list add remove doctor sync mappings discover setup help" -f -a "remove" -d 'Remove a configured source'
complete -c cass -n "__fish_cass_using_subcommand sources; and not __fish_seen_subcommand_from list add remove doctor sync mappings discover setup help" -f -a "doctor" -d 'Diagnose source connectivity and configuration issues'
complete -c cass -n "__fish_cass_using_subcommand sources; and not __fish_seen_subcommand_from list add remove doctor sync mappings discover setup help" -f -a "sync" -d 'Synchronize sessions from remote sources'
complete -c cass -n "__fish_cass_using_subcommand sources; and not __fish_seen_subcommand_from list add remove doctor sync mappings discover setup help" -f -a "mappings" -d 'Manage path mappings for a source (P6.3)'
complete -c cass -n "__fish_cass_using_subcommand sources; and not __fish_seen_subcommand_from list add remove doctor sync mappings discover setup help" -f -a "discover" -d 'Auto-discover SSH hosts from ~/.ssh/config'
complete -c cass -n "__fish_cass_using_subcommand sources; and not __fish_seen_subcommand_from list add remove doctor sync mappings discover setup help" -f -a "setup" -d 'Interactive wizard to discover, configure, and set up remote sources'
complete -c cass -n "__fish_cass_using_subcommand sources; and not __fish_seen_subcommand_from list add remove doctor sync mappings discover setup help" -f -a "help" -d 'Print this message or the help of the given subcommand(s)'
complete -c cass -n "__fish_cass_using_subcommand sources; and __fish_seen_subcommand_from list" -s v -l verbose -d 'Show detailed information'
complete -c cass -n "__fish_cass_using_subcommand sources; and __fish_seen_subcommand_from list" -l json -l robot -d 'Output as JSON'
complete -c cass -n "__fish_cass_using_subcommand sources; and __fish_seen_subcommand_from list" -s h -l help -d 'Print help'
complete -c cass -n "__fish_cass_using_subcommand sources; and __fish_seen_subcommand_from add" -l name -d 'Friendly name for this source (becomes source_id)' -r
complete -c cass -n "__fish_cass_using_subcommand sources; and __fish_seen_subcommand_from add" -l preset -d 'Use preset paths for platform (macos-defaults, linux-defaults)' -r
complete -c cass -n "__fish_cass_using_subcommand sources; and __fish_seen_subcommand_from add" -s p -l path -d 'Paths to sync (can be specified multiple times)' -r
complete -c cass -n "__fish_cass_using_subcommand sources; and __fish_seen_subcommand_from add" -l no-test -d 'Skip connectivity test'
complete -c cass -n "__fish_cass_using_subcommand sources; and __fish_seen_subcommand_from add" -s h -l help -d 'Print help'
complete -c cass -n "__fish_cass_using_subcommand sources; and __fish_seen_subcommand_from remove" -l purge -d 'Also delete synced session data from index'
complete -c cass -n "__fish_cass_using_subcommand sources; and __fish_seen_subcommand_from remove" -s y -l yes -d 'Skip confirmation prompt'
complete -c cass -n "__fish_cass_using_subcommand sources; and __fish_seen_subcommand_from remove" -s h -l help -d 'Print help'
complete -c cass -n "__fish_cass_using_subcommand sources; and __fish_seen_subcommand_from doctor" -s s -l source -d 'Check only specific source (defaults to all)' -r
complete -c cass -n "__fish_cass_using_subcommand sources; and __fish_seen_subcommand_from doctor" -l json -l robot -d 'Output as JSON'
complete -c cass -n "__fish_cass_using_subcommand sources; and __fish_seen_subcommand_from doctor" -s h -l help -d 'Print help'
complete -c cass -n "__fish_cass_using_subcommand sources; and __fish_seen_subcommand_from sync" -s s -l source -d 'Sync only specific source(s)' -r
complete -c cass -n "__fish_cass_using_subcommand sources; and __fish_seen_subcommand_from sync" -l no-index -d 'Don\'t re-index after sync'
complete -c cass -n "__fish_cass_using_subcommand sources; and __fish_seen_subcommand_from sync" -s v -l verbose -d 'Show detailed transfer information'
complete -c cass -n "__fish_cass_using_subcommand sources; and __fish_seen_subcommand_from sync" -l dry-run -d 'Dry run - show what would be synced without actually syncing'
complete -c cass -n "__fish_cass_using_subcommand sources; and __fish_seen_subcommand_from sync" -l json -l robot -d 'Output as JSON'
complete -c cass -n "__fish_cass_using_subcommand sources; and __fish_seen_subcommand_from sync" -s h -l help -d 'Print help'
complete -c cass -n "__fish_cass_using_subcommand sources; and __fish_seen_subcommand_from mappings" -s h -l help -d 'Print help'
complete -c cass -n "__fish_cass_using_subcommand sources; and __fish_seen_subcommand_from mappings" -f -a "list" -d 'List path mappings for a source'
complete -c cass -n "__fish_cass_using_subcommand sources; and __fish_seen_subcommand_from mappings" -f -a "add" -d 'Add a path mapping'
complete -c cass -n "__fish_cass_using_subcommand sources; and __fish_seen_subcommand_from mappings" -f -a "remove" -d 'Remove a path mapping by index'
complete -c cass -n "__fish_cass_using_subcommand sources; and __fish_seen_subcommand_from mappings" -f -a "test" -d 'Test how a path would be rewritten'
complete -c cass -n "__fish_cass_using_subcommand sources; and __fish_seen_subcommand_from mappings" -f -a "help" -d 'Print this message or the help of the given subcommand(s)'
complete -c cass -n "__fish_cass_using_subcommand sources; and __fish_seen_subcommand_from discover" -l preset -d 'Platform preset for default paths (macos-defaults, linux-defaults)' -r
complete -c cass -n "__fish_cass_using_subcommand sources; and __fish_seen_subcommand_from discover" -l skip-existing -d 'Skip hosts that are already configured as sources'
complete -c cass -n "__fish_cass_using_subcommand sources; and __fish_seen_subcommand_from discover" -l json -l robot -d 'Output as JSON'
complete -c cass -n "__fish_cass_using_subcommand sources; and __fish_seen_subcommand_from discover" -s h -l help -d 'Print help'
complete -c cass -n "__fish_cass_using_subcommand sources; and __fish_seen_subcommand_from setup" -l hosts -d 'Configure only these hosts (comma-separated SSH aliases, skips discovery/selection)' -r
complete -c cass -n "__fish_cass_using_subcommand sources; and __fish_seen_subcommand_from setup" -l timeout -d 'SSH connection timeout in seconds' -r
complete -c cass -n "__fish_cass_using_subcommand sources; and __fish_seen_subcommand_from setup" -l dry-run -d 'Preview what would happen without making changes'
complete -c cass -n "__fish_cass_using_subcommand sources; and __fish_seen_subcommand_from setup" -l non-interactive -d 'Skip interactive prompts (use auto-detected defaults for scripting)'
complete -c cass -n "__fish_cass_using_subcommand sources; and __fish_seen_subcommand_from setup" -l skip-install -d 'Skip cass installation on remotes that don\'t have it'
complete -c cass -n "__fish_cass_using_subcommand sources; and __fish_seen_subcommand_from setup" -l skip-index -d 'Skip running `cass index` on remotes'
complete -c cass -n "__fish_cass_using_subcommand sources; and __fish_seen_subcommand_from setup" -l skip-sync -d 'Skip syncing data after setup completes'
complete -c cass -n "__fish_cass_using_subcommand sources; and __fish_seen_subcommand_from setup" -l resume -d 'Resume from previous interrupted setup (reads ~/.config/cass/setup_state.json)'
complete -c cass -n "__fish_cass_using_subcommand sources; and __fish_seen_subcommand_from setup" -s v -l verbose -d 'Show detailed progress output'
complete -c cass -n "__fish_cass_using_subcommand sources; and __fish_seen_subcommand_from setup" -l json -l robot -d 'Output progress as JSON (implies non-interactive, for scripting)'
complete -c cass -n "__fish_cass_using_subcommand sources; and __fish_seen_subcommand_from setup" -s h -l help -d 'Print help (see more with \'--help\')'
complete -c cass -n "__fish_cass_using_subcommand sources; and __fish_seen_subcommand_from help" -f -a "list" -d 'List configured sources'
complete -c cass -n "__fish_cass_using_subcommand sources; and __fish_seen_subcommand_from help" -f -a "add" -d 'Add a new remote source'
complete -c cass -n "__fish_cass_using_subcommand sources; and __fish_seen_subcommand_from help" -f -a "remove" -d 'Remove a configured source'
complete -c cass -n "__fish_cass_using_subcommand sources; and __fish_seen_subcommand_from help" -f -a "doctor" -d 'Diagnose source connectivity and configuration issues'
complete -c cass -n "__fish_cass_using_subcommand sources; and __fish_seen_subcommand_from help" -f -a "sync" -d 'Synchronize sessions from remote sources'
complete -c cass -n "__fish_cass_using_subcommand sources; and __fish_seen_subcommand_from help" -f -a "mappings" -d 'Manage path mappings for a source (P6.3)'
complete -c cass -n "__fish_cass_using_subcommand sources; and __fish_seen_subcommand_from help" -f -a "discover" -d 'Auto-discover SSH hosts from ~/.ssh/config'
complete -c cass -n "__fish_cass_using_subcommand sources; and __fish_seen_subcommand_from help" -f -a "setup" -d 'Interactive wizard to discover, configure, and set up remote sources'
complete -c cass -n "__fish_cass_using_subcommand sources; and __fish_seen_subcommand_from help" -f -a "help" -d 'Print this message or the help of the given subcommand(s)'
complete -c cass -n "__fish_cass_using_subcommand models; and not __fish_seen_subcommand_from status install verify remove check-update help" -s h -l help -d 'Print help'
complete -c cass -n "__fish_cass_using_subcommand models; and not __fish_seen_subcommand_from status install verify remove check-update help" -f -a "status" -d 'Show model installation status'
complete -c cass -n "__fish_cass_using_subcommand models; and not __fish_seen_subcommand_from status install verify remove check-update help" -f -a "install" -d 'Download and install the semantic search model'
complete -c cass -n "__fish_cass_using_subcommand models; and not __fish_seen_subcommand_from status install verify remove check-update help" -f -a "verify" -d 'Verify model integrity (SHA256 checksums)'
complete -c cass -n "__fish_cass_using_subcommand models; and not __fish_seen_subcommand_from status install verify remove check-update help" -f -a "remove" -d 'Remove model files to free disk space'
complete -c cass -n "__fish_cass_using_subcommand models; and not __fish_seen_subcommand_from status install verify remove check-update help" -f -a "check-update" -d 'Check for model updates'
complete -c cass -n "__fish_cass_using_subcommand models; and not __fish_seen_subcommand_from status install verify remove check-update help" -f -a "help" -d 'Print this message or the help of the given subcommand(s)'
complete -c cass -n "__fish_cass_using_subcommand models; and __fish_seen_subcommand_from status" -l json -l robot -d 'Output as JSON'
complete -c cass -n "__fish_cass_using_subcommand models; and __fish_seen_subcommand_from status" -s h -l help -d 'Print help'
complete -c cass -n "__fish_cass_using_subcommand models; and __fish_seen_subcommand_from install" -l model -d 'Model to install (default: all-minilm-l6-v2)' -r
complete -c cass -n "__fish_cass_using_subcommand models; and __fish_seen_subcommand_from install" -l mirror -d 'Custom mirror URL for downloading' -r
complete -c cass -n "__fish_cass_using_subcommand models; and __fish_seen_subcommand_from install" -l from-file -d 'Install from local file (for air-gapped environments)' -r -F
complete -c cass -n "__fish_cass_using_subcommand models; and __fish_seen_subcommand_from install" -l data-dir -d 'Override data dir' -r -F
complete -c cass -n "__fish_cass_using_subcommand models; and __fish_seen_subcommand_from install" -s y -l yes -d 'Skip confirmation prompt'
complete -c cass -n "__fish_cass_using_subcommand models; and __fish_seen_subcommand_from install" -s h -l help -d 'Print help'
complete -c cass -n "__fish_cass_using_subcommand models; and __fish_seen_subcommand_from verify" -l data-dir -d 'Override data dir' -r -F
complete -c cass -n "__fish_cass_using_subcommand models; and __fish_seen_subcommand_from verify" -l repair -d 'Attempt to repair corrupted files'
complete -c cass -n "__fish_cass_using_subcommand models; and __fish_seen_subcommand_from verify" -l json -l robot -d 'Output as JSON'
complete -c cass -n "__fish_cass_using_subcommand models; and __fish_seen_subcommand_from verify" -s h -l help -d 'Print help'
complete -c cass -n "__fish_cass_using_subcommand models; and __fish_seen_subcommand_from remove" -l model -d 'Model to remove (default: all-minilm-l6-v2)' -r
complete -c cass -n "__fish_cass_using_subcommand models; and __fish_seen_subcommand_from remove" -l data-dir -d 'Override data dir' -r -F
complete -c cass -n "__fish_cass_using_subcommand models; and __fish_seen_subcommand_from remove" -s y -l yes -d 'Skip confirmation prompt'
complete -c cass -n "__fish_cass_using_subcommand models; and __fish_seen_subcommand_from remove" -s h -l help -d 'Print help'
complete -c cass -n "__fish_cass_using_subcommand models; and __fish_seen_subcommand_from check-update" -l data-dir -d 'Override data dir' -r -F
complete -c cass -n "__fish_cass_using_subcommand models; and __fish_seen_subcommand_from check-update" -l json -l robot -d 'Output as JSON'
complete -c cass -n "__fish_cass_using_subcommand models; and __fish_seen_subcommand_from check-update" -s h -l help -d 'Print help'
complete -c cass -n "__fish_cass_using_subcommand models; and __fish_seen_subcommand_from help" -f -a "status" -d 'Show model installation status'
complete -c cass -n "__fish_cass_using_subcommand models; and __fish_seen_subcommand_from help" -f -a "install" -d 'Download and install the semantic search model'
complete -c cass -n "__fish_cass_using_subcommand models; and __fish_seen_subcommand_from help" -f -a "verify" -d 'Verify model integrity (SHA256 checksums)'
complete -c cass -n "__fish_cass_using_subcommand models; and __fish_seen_subcommand_from help" -f -a "remove" -d 'Remove model files to free disk space'
complete -c cass -n "__fish_cass_using_subcommand models; and __fish_seen_subcommand_from help" -f -a "check-update" -d 'Check for model updates'
complete -c cass -n "__fish_cass_using_subcommand models; and __fish_seen_subcommand_from help" -f -a "help" -d 'Print this message or the help of the given subcommand(s)'
complete -c cass -n "__fish_cass_using_subcommand import; and not __fish_seen_subcommand_from chatgpt help" -s h -l help -d 'Print help'
complete -c cass -n "__fish_cass_using_subcommand import; and not __fish_seen_subcommand_from chatgpt help" -f -a "chatgpt" -d 'Import ChatGPT web export (conversations.json)'
complete -c cass -n "__fish_cass_using_subcommand import; and not __fish_seen_subcommand_from chatgpt help" -f -a "help" -d 'Print this message or the help of the given subcommand(s)'
complete -c cass -n "__fish_cass_using_subcommand import; and __fish_seen_subcommand_from chatgpt" -l output-dir -d 'Output directory (default: ChatGPT app support dir on macOS, or ~/.local/share/cass/chatgpt/ on Linux)' -r -F
complete -c cass -n "__fish_cass_using_subcommand import; and __fish_seen_subcommand_from chatgpt" -l json -l robot -d 'Output as JSON'
complete -c cass -n "__fish_cass_using_subcommand import; and __fish_seen_subcommand_from chatgpt" -s h -l help -d 'Print help (see more with \'--help\')'
complete -c cass -n "__fish_cass_using_subcommand import; and __fish_seen_subcommand_from help" -f -a "chatgpt" -d 'Import ChatGPT web export (conversations.json)'
complete -c cass -n "__fish_cass_using_subcommand import; and __fish_seen_subcommand_from help" -f -a "help" -d 'Print this message or the help of the given subcommand(s)'
complete -c cass -n "__fish_cass_using_subcommand help; and not __fish_seen_subcommand_from tui index completions man robot-docs search stats diag status capabilities state api-version introspect view health doctor context export export-html expand timeline pages sources models import help" -f -a "tui" -d 'Launch interactive TUI'
complete -c cass -n "__fish_cass_using_subcommand help; and not __fish_seen_subcommand_from tui index completions man robot-docs search stats diag status capabilities state api-version introspect view health doctor context export export-html expand timeline pages sources models import help" -f -a "index" -d 'Run indexer'
complete -c cass -n "__fish_cass_using_subcommand help; and not __fish_seen_subcommand_from tui index completions man robot-docs search stats diag status capabilities state api-version introspect view health doctor context export export-html expand timeline pages sources models import help" -f -a "completions" -d 'Generate shell completions to stdout'
complete -c cass -n "__fish_cass_using_subcommand help; and not __fish_seen_subcommand_from tui index completions man robot-docs search stats diag status capabilities state api-version introspect view health doctor context export export-html expand timeline pages sources models import help" -f -a "man" -d 'Generate man page to stdout'
complete -c cass -n "__fish_cass_using_subcommand help; and not __fish_seen_subcommand_from tui index completions man robot-docs search stats diag status capabilities state api-version introspect view health doctor context export export-html expand timeline pages sources models import help" -f -a "robot-docs" -d 'Machine-focused docs for automation agents'
complete -c cass -n "__fish_cass_using_subcommand help; and not __fish_seen_subcommand_from tui index completions man robot-docs search stats diag status capabilities state api-version introspect view health doctor context export export-html expand timeline pages sources models import help" -f -a "search" -d 'Run a one-off search and print results to stdout'
complete -c cass -n "__fish_cass_using_subcommand help; and not __fish_seen_subcommand_from tui index completions man robot-docs search stats diag status capabilities state api-version introspect view health doctor context export export-html expand timeline pages sources models import help" -f -a "stats" -d 'Show statistics about indexed data'
complete -c cass -n "__fish_cass_using_subcommand help; and not __fish_seen_subcommand_from tui index completions man robot-docs search stats diag status capabilities state api-version introspect view health doctor context export export-html expand timeline pages sources models import help" -f -a "diag" -d 'Output diagnostic information for troubleshooting'
complete -c cass -n "__fish_cass_using_subcommand help; and not __fish_seen_subcommand_from tui index completions man robot-docs search stats diag status capabilities state api-version introspect view health doctor context export export-html expand timeline pages sources models import help" -f -a "status" -d 'Quick health check for agents: index freshness, db stats, recommended action'
complete -c cass -n "__fish_cass_using_subcommand help; and not __fish_seen_subcommand_from tui index completions man robot-docs search stats diag status capabilities state api-version introspect view health doctor context export export-html expand timeline pages sources models import help" -f -a "capabilities" -d 'Discover available features, versions, and limits for agent introspection'
complete -c cass -n "__fish_cass_using_subcommand help; and not __fish_seen_subcommand_from tui index completions man robot-docs search stats diag status capabilities state api-version introspect view health doctor context export export-html expand timeline pages sources models import help" -f -a "state" -d 'Quick state/health check (alias of status)'
complete -c cass -n "__fish_cass_using_subcommand help; and not __fish_seen_subcommand_from tui index completions man robot-docs search stats diag status capabilities state api-version introspect view health doctor context export export-html expand timeline pages sources models import help" -f -a "api-version" -d 'Show API + contract version info'
complete -c cass -n "__fish_cass_using_subcommand help; and not __fish_seen_subcommand_from tui index completions man robot-docs search stats diag status capabilities state api-version introspect view health doctor context export export-html expand timeline pages sources models import help" -f -a "introspect" -d 'Full API schema introspection - commands, arguments, and response schemas'
complete -c cass -n "__fish_cass_using_subcommand help; and not __fish_seen_subcommand_from tui index completions man robot-docs search stats diag status capabilities state api-version introspect view health doctor context export export-html expand timeline pages sources models import help" -f -a "view" -d 'View a source file at a specific line (follow up on search results)'
complete -c cass -n "__fish_cass_using_subcommand help; and not __fish_seen_subcommand_from tui index completions man robot-docs search stats diag status capabilities state api-version introspect view health doctor context export export-html expand timeline pages sources models import help" -f -a "health" -d 'Minimal health check (<50ms). Exit 0=healthy, 1=unhealthy. For agent pre-flight checks'
complete -c cass -n "__fish_cass_using_subcommand help; and not __fish_seen_subcommand_from tui index completions man robot-docs search stats diag status capabilities state api-version introspect view health doctor context export export-html expand timeline pages sources models import help" -f -a "doctor" -d 'Diagnose and repair cass installation issues. Safe by default - never deletes user data. Use --fix to apply automatic repairs (rebuilds derived data only, preserves source sessions)'
complete -c cass -n "__fish_cass_using_subcommand help; and not __fish_seen_subcommand_from tui index completions man robot-docs search stats diag status capabilities state api-version introspect view health doctor context export export-html expand timeline pages sources models import help" -f -a "context" -d 'Find related sessions for a given source path'
complete -c cass -n "__fish_cass_using_subcommand help; and not __fish_seen_subcommand_from tui index completions man robot-docs search stats diag status capabilities state api-version introspect view health doctor context export export-html expand timeline pages sources models import help" -f -a "export" -d 'Export a conversation to markdown or other formats'
complete -c cass -n "__fish_cass_using_subcommand help; and not __fish_seen_subcommand_from tui index completions man robot-docs search stats diag status capabilities state api-version introspect view health doctor context export export-html expand timeline pages sources models import help" -f -a "export-html" -d 'Export session as beautiful, self-contained HTML (with optional encryption)'
complete -c cass -n "__fish_cass_using_subcommand help; and not __fish_seen_subcommand_from tui index completions man robot-docs search stats diag status capabilities state api-version introspect view health doctor context export export-html expand timeline pages sources models import help" -f -a "expand" -d 'Show messages around a specific line in a session file'
complete -c cass -n "__fish_cass_using_subcommand help; and not __fish_seen_subcommand_from tui index completions man robot-docs search stats diag status capabilities state api-version introspect view health doctor context export export-html expand timeline pages sources models import help" -f -a "timeline" -d 'Show activity timeline for a time range'
complete -c cass -n "__fish_cass_using_subcommand help; and not __fish_seen_subcommand_from tui index completions man robot-docs search stats diag status capabilities state api-version introspect view health doctor context export export-html expand timeline pages sources models import help" -f -a "pages" -d 'Export encrypted searchable archive for static hosting (P4.x)'
complete -c cass -n "__fish_cass_using_subcommand help; and not __fish_seen_subcommand_from tui index completions man robot-docs search stats diag status capabilities state api-version introspect view health doctor context export export-html expand timeline pages sources models import help" -f -a "sources" -d 'Manage remote sources (P5.x)'
complete -c cass -n "__fish_cass_using_subcommand help; and not __fish_seen_subcommand_from tui index completions man robot-docs search stats diag status capabilities state api-version introspect view health doctor context export export-html expand timeline pages sources models import help" -f -a "models" -d 'Manage semantic search models'
complete -c cass -n "__fish_cass_using_subcommand help; and not __fish_seen_subcommand_from tui index completions man robot-docs search stats diag status capabilities state api-version introspect view health doctor context export export-html expand timeline pages sources models import help" -f -a "import" -d 'Import data from external sources'
complete -c cass -n "__fish_cass_using_subcommand help; and not __fish_seen_subcommand_from tui index completions man robot-docs search stats diag status capabilities state api-version introspect view health doctor context export export-html expand timeline pages sources models import help" -f -a "help" -d 'Print this message or the help of the given subcommand(s)'
complete -c cass -n "__fish_cass_using_subcommand help; and __fish_seen_subcommand_from sources" -f -a "list" -d 'List configured sources'
complete -c cass -n "__fish_cass_using_subcommand help; and __fish_seen_subcommand_from sources" -f -a "add" -d 'Add a new remote source'
complete -c cass -n "__fish_cass_using_subcommand help; and __fish_seen_subcommand_from sources" -f -a "remove" -d 'Remove a configured source'
complete -c cass -n "__fish_cass_using_subcommand help; and __fish_seen_subcommand_from sources" -f -a "doctor" -d 'Diagnose source connectivity and configuration issues'
complete -c cass -n "__fish_cass_using_subcommand help; and __fish_seen_subcommand_from sources" -f -a "sync" -d 'Synchronize sessions from remote sources'
complete -c cass -n "__fish_cass_using_subcommand help; and __fish_seen_subcommand_from sources" -f -a "mappings" -d 'Manage path mappings for a source (P6.3)'
complete -c cass -n "__fish_cass_using_subcommand help; and __fish_seen_subcommand_from sources" -f -a "discover" -d 'Auto-discover SSH hosts from ~/.ssh/config'
complete -c cass -n "__fish_cass_using_subcommand help; and __fish_seen_subcommand_from sources" -f -a "setup" -d 'Interactive wizard to discover, configure, and set up remote sources'
complete -c cass -n "__fish_cass_using_subcommand help; and __fish_seen_subcommand_from models" -f -a "status" -d 'Show model installation status'
complete -c cass -n "__fish_cass_using_subcommand help; and __fish_seen_subcommand_from models" -f -a "install" -d 'Download and install the semantic search model'
complete -c cass -n "__fish_cass_using_subcommand help; and __fish_seen_subcommand_from models" -f -a "verify" -d 'Verify model integrity (SHA256 checksums)'
complete -c cass -n "__fish_cass_using_subcommand help; and __fish_seen_subcommand_from models" -f -a "remove" -d 'Remove model files to free disk space'
complete -c cass -n "__fish_cass_using_subcommand help; and __fish_seen_subcommand_from models" -f -a "check-update" -d 'Check for model updates'
complete -c cass -n "__fish_cass_using_subcommand help; and __fish_seen_subcommand_from import" -f -a "chatgpt" -d 'Import ChatGPT web export (conversations.json)'
