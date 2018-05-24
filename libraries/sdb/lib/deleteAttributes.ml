open Types
open Aws
type input = DeleteAttributesRequest.t
type output = unit
type error = Errors.t
let service = "sdb" 
let to_http req =
  let uri =
    Uri.add_query_params (Uri.of_string "https://sdb.amazonaws.com")
      (List.append
         [("Version", ["2009-04-15"]); ("Action", ["DeleteAttributes"])]
         (Util.drop_empty
            (Uri.query_of_encoded
               (Query.render (DeleteAttributesRequest.to_query req)))))
     in
  (`POST, uri, []) 
let of_http body = `Ok () 
let parse_error code err =
  let errors =
    [Errors.AttributeDoesNotExist;
    Errors.NoSuchDomain;
    Errors.MissingParameter;
    Errors.InvalidParameterValue] @ Errors.common  in
  match Errors.of_string err with
  | Some var ->
      if
        (List.mem var errors) &&
          ((match Errors.to_http_code var with
            | Some var -> var = code
            | None  -> true))
      then Some var
      else None
  | None  -> None 