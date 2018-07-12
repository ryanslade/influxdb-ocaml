open Base
open Lwt
open Cohttp
open Cohttp_lwt_unix

type ping_response = {
  build : string;
  version : string;
}

let fail_if_http_error resp body =
  let code = resp |> Response.status |> Code.code_of_status in
  if Code.is_error code
  then 
    Cohttp_lwt.Body.to_string body >>= fun text ->
    fail_with (Printf.sprintf "HTTP error: %s" text)
  else 
    return_unit

let ping ?(port=8086) host =
  let uri = Uri.make ~scheme:"http" ~host ~port ~path:"ping" () in
  Client.get uri >>= fun (resp, body) ->
  fail_if_http_error resp body >>= fun () ->
  let headers = Response.headers resp in
  let build = Cohttp.Header.get headers "X-Influxdb-Build" in
  let version = Cohttp.Header.get headers "X-Influxdb-Version" in
  match Option.both build version with
  | None -> fail_with "Missing ping headers"
  | Some (build, version) ->
    return {
      build;
      version;
    }

let write ?(precision=Influxdb.Precision.Nanosecond) ?(port=8086) ~database ~points host =
  if List.is_empty points then fail_with "No points"
  else
    let body = List.map ~f:(Influxdb.Point.to_line ~precision) points |> String.concat ~sep:"\n" |> Cohttp_lwt.Body.of_string in
    let uri = Uri.make ~scheme:"http" ~host ~port ~path:"write" 
        ~query:([
            ("db", [database]);
            ("precision",[Influxdb.Precision.to_string precision])
          ]) 
        () 
    in
    Client.post ~body uri >>= fun (resp, body) ->
    fail_if_http_error resp body
