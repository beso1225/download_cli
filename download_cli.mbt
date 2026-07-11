// Main package file for your library code.
// Put public APIs and shared helpers here.
// Keep blocks small and focused for easy refactors.

///|
pub struct Config {
  url : String
  output : String?
} derive(Eq)

///|
pub fn command() -> @argparse.Command {
  @argparse.Command(
    "moon-fetch",
    about="Download a URL to stdout or a file",
    options=[
      @argparse.OptionArg(
        "output",
        short='o',
        about="Write the response body to this file",
      ),
    ],
    positionals=[
      @argparse.PositionArg(
        "url",
        about="HTTP or HTTPS URL to download",
        num_args=@argparse.ValueRange::single(),
      ),
    ],
  )
}

///|
pub fn parse_config(argv : ArrayView[String]) -> Config raise {
  let matches = @argparse.parse(command(), argv~)
  let values : Map[String, Array[String]] = matches.values
  guard values is { "url": [url], "output"? : output_path, .. } else {
    fail("missing url")
  }
  let output = match output_path {
    Some([output, ..]) => Some(output)
    _ => None
  }
  { url, output }
}

///|
pub async fn run(config : Config) -> Unit {
  let (response, body) = @http.get_stream(config.url)
  defer body.close()

  guard response.code is (200..<300) else {
    fail("download failed: \{response.code} \{response.reason}")
  }

  match config.output {
    Some(path) => {
      let file = @fs.create(path, permission=0o644)
      defer file.close()
      @stdio.stderr.write("saved \{config.url} to \{path}\n")
    }
    None => @stdio.stdout.write_reader(body)
  }
}
