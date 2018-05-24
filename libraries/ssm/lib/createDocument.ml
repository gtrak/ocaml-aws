open Types
open Aws
type input = CreateDocumentRequest.t
type output = CreateDocumentResult.t
type error = Errors.t
let service = "ssm" 
let to_http req =
  let uri =
    Uri.add_query_params (Uri.of_string "https://ssm.amazonaws.com")
      (List.append
         [("Version", ["2014-11-06"]); ("Action", ["CreateDocument"])]
         (Util.drop_empty
            (Uri.query_of_encoded
               (Query.render (CreateDocumentRequest.to_query req)))))
     in
  (`POST, uri, []) 
let of_http body =
  try
    let xml = Ezxmlm.from_string body  in
    let resp = Xml.member "CreateDocumentResponse" (snd xml)  in
    try
      Util.or_error (Util.option_bind resp CreateDocumentResult.parse)
        (let open Error in
           BadResponse
             {
               body;
               message = "Could not find well formed CreateDocumentResult."
             })
    with
    | Xml.RequiredFieldMissing msg ->
        let open Error in
          `Error
            (BadResponse
               {
                 body;
                 message =
                   ("Error parsing CreateDocumentResult - missing field in body or children: "
                      ^ msg)
               })
  with
  | Failure msg ->
      `Error
        (let open Error in
           BadResponse { body; message = ("Error parsing xml: " ^ msg) })
  
let parse_error code err =
  let errors =
    [Errors.DocumentLimitExceeded;
    Errors.InvalidDocumentContent;
    Errors.InternalServerError;
    Errors.MaxDocumentSizeExceeded;
    Errors.DocumentAlreadyExists] @ Errors.common  in
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