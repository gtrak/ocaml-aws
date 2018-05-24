open Types
open Aws
type input = CreateTrailRequest.t
type output = CreateTrailResponse.t
type error = Errors.t
let service = "cloudtrail" 
let to_http req =
  let uri =
    Uri.add_query_params (Uri.of_string "https://cloudtrail.amazonaws.com")
      (List.append [("Version", ["2013-11-01"]); ("Action", ["CreateTrail"])]
         (Util.drop_empty
            (Uri.query_of_encoded
               (Query.render (CreateTrailRequest.to_query req)))))
     in
  (`POST, uri, []) 
let of_http body =
  try
    let xml = Ezxmlm.from_string body  in
    let resp = Xml.member "CreateTrailResponse" (snd xml)  in
    try
      Util.or_error (Util.option_bind resp CreateTrailResponse.parse)
        (let open Error in
           BadResponse
             {
               body;
               message = "Could not find well formed CreateTrailResponse."
             })
    with
    | Xml.RequiredFieldMissing msg ->
        let open Error in
          `Error
            (BadResponse
               {
                 body;
                 message =
                   ("Error parsing CreateTrailResponse - missing field in body or children: "
                      ^ msg)
               })
  with
  | Failure msg ->
      `Error
        (let open Error in
           BadResponse { body; message = ("Error parsing xml: " ^ msg) })
  
let parse_error code err =
  let errors =
    [Errors.CloudWatchLogsDeliveryUnavailable;
    Errors.InvalidCloudWatchLogsRoleArn;
    Errors.InvalidCloudWatchLogsLogGroupArn;
    Errors.InvalidTrailName;
    Errors.InvalidSnsTopicName;
    Errors.InvalidS3Prefix;
    Errors.InvalidS3BucketName;
    Errors.InsufficientSnsTopicPolicy;
    Errors.InsufficientS3BucketPolicy;
    Errors.S3BucketDoesNotExist;
    Errors.TrailAlreadyExists;
    Errors.MaximumNumberOfTrailsExceeded] @ Errors.common  in
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