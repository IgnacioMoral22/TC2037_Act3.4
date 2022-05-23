# Reto1.get_captures('Test_files/example_5.json', 'a.txt')
defmodule Reto1 do
  @moduledoc """
  Elixir JSON Syntax Highlighter
  Ignacio Joaquin Moral - A01028470
  Alfredo Jeong Hyun Park - A01658259
  """

  @doc """
  Get the values from the input file. Send to an output file specified by the user
  CHANGE: auto-generate an html file
  """
  def get_captures(in_filename) do
    time1 = Time.utc_now()
    captures =
      in_filename
      |> File.stream!()
      |> Enum.map(&start_recognition/1)
      |> Enum.join("")
    html = """
    <!DOCTYPE html>
    <html>
      <head>
      <title>JSON Code</title>
      <link rel="stylesheet" href="token_colors.css" />
      </head>
      <body>
        <h1>May 22, 2022</h1>
        <pre>
    #{captures}
        </pre>
      </body>
    </html>
    """
    File.write('output.html', html)
    time2 = Time.utc_now()
    IO.puts(time1)
    IO.puts(time2)
  end

  @doc """
  Default start function. Allows sending values to recognize_values while keeping the pipeline format.
  Used to avoid troubles with Enum.map
  """
  defp start_recognition(line) do
    recognize_values(line, "")
  end

  @doc """
  Recursive function. Receives the line and all the span classes found in said line. Starts with 0 spanClasses.
  If there's nothing to remove, returns the span classes found.
  If there's still text, it will recurse until the string is empty, adding the span classes found along the way.
  """
  defp recognize_values(line, spanClasses) do
    if String.length(line) == 0 do
      spanClasses
    else
      tuple = email_from_line(line)
      recognize_values(elem(tuple, 0), spanClasses <> elem(tuple, 1))
    end
  end

  @doc """
  Identify different points in the string sent. Keys, strings, numbers, boolean values,
  and separations like [, ], {, }, and commas
  """
  defp email_from_line(line) do
    keys = Regex.run(~r|((\s*)?(\")\w+([-:_]?\w+)+(\"\s*\:)(\s*)?)|, line, [capture: :first, return: :index])
    strings = Regex.run(~r|((\s*)?\"([-\s\w\/:.,=;*&@()+?']*)\")|, line, [capture: :first, return: :index])
    numbers = Regex.run(~r|((-?\d*)((.)?\d)([eE][+-]?\d)?)|, line, [capture: :first, return: :index])
    bools = Regex.run(~r/(true|false|True|False|null|NULL)/, line, [capture: :first, return: :index])
    separations = Regex.run(~r|(\s*)?[{}[\],]?(\s*)?|, line, [capture: :first, return: :index])
    cond do
      keys != nil -> capture_values(List.first(keys), 'object-key', line)
      strings != nil -> capture_values(List.first(strings), 'string', line)
      numbers != nil -> capture_values(List.first(numbers), 'number', line)
      bools != nil -> capture_values(List.first(bools), 'reserved-word', line)
      separations != nil -> capture_punctuation(List.first(separations), 'puctuation', line)
    end
  end

  @doc """
  Default capture function. Splits the original line sent to get the value identified, sends to create a span, removes the
  section from the line, and sends back a tuple. The tuple is done in order to send more than one value back, in
  this case, the span and the modified line
  """
  defp capture_values(index, value, line) do
    capture = String.slice(line, elem(index, 0), elem(index, 1))
    span = create_span(capture, value)
    line = String.replace(line, capture, "")
    tuple = {line, span}
    tuple
  end

  @doc """
  Separates puntuations. Works similar to the previous one, but only removes the first instance of the value found, not the
  multiple possible values.
  """
  defp capture_punctuation(index, value, line) do
    capture = String.slice(line, elem(index, 0), elem(index, 1))
    span = create_span(capture, value)
    line = String.replace_prefix(line, capture, "")
    tuple = {line, span}
    tuple
  end

  @doc """
  Default function to generate spans. Takes the value found and the string found, and inserts it.
  """
  defp create_span(line, value_found) do
    "<span class=\"#{value_found}\">#{line}</span>"
  end

end
