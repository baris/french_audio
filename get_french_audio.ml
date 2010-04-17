
open Printf
open Nethtml
open Http_client.Convenience

let f_about_com = "http://french.about.com"
let base_audio_dict_url = f_about_com ^ "/od/vocabulary/a/audiodictionary.htm"
let letter_url letter = f_about_com ^ "/library/pronunciation/bl-audiodico-" ^ letter ^ ".htm"
let wav_url wav = f_about_com ^ "/library/media/wavs/" ^ wav
let wavs_dir = "wavs"

let parse_page page = 
  let ch = new Netchannels.input_string page in
  parse ch


let get_page_for_letter letter =
  http_get (letter_url letter)


let get_wav path =
  let file = List.hd (List.rev (Neturl.split_path path)) in
  let url = wav_url file in
  let f = open_out_bin (Neturl.join_path [wavs_dir; file]) in
  printf "Downloading file %s\n" file; flush stdout;
  output_string f (http_get url);
  close_out f
    

let rec get_words doc =
  let try_download attr = 
    let media_regexp = Str.regexp "^\\.\\./media/wavs.*" in
    match attr with
      ("href", path) -> if (Str.string_match media_regexp path 0) then (ignore (get_wav path))
    | _ -> () in
  match doc with
    Element(name, attrs, subnodes) -> begin
      List.iter try_download attrs;
      List.iter get_words subnodes
    end
  | Data s -> ()


let get_words_for_letter letter =
  let page = get_page_for_letter letter in
  List.iter get_words (parse_page page)


let _ = 
  try Unix.mkdir "wavs" 0o775 with _ -> ();;

  let threads = ref [] in
  for c = (int_of_char 'a') to (int_of_char 'z') do
    let letter = (Char.escaped (char_of_int c)) in
    let t = Thread.create get_words_for_letter letter in
    threads := t :: !threads
  done;
  List.iter Thread.join !threads

