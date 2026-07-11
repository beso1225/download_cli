///|
/// Entry point for the CLI or runnable program in this template.
/// Keep main focused; move logic into the library package.
/// Run with `moon run cmd/main` from the project root.
async fn main {
  let argv = @env.args()
  let config = @app.parse_config(argv[1:])
  @app.run(config)
}
