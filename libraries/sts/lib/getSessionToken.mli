open Types
type input = GetSessionTokenRequest.t
type output = GetSessionTokenResponse.t
type error = Errors.t
include
  (Aws.Call with type  input :=  input and type  output :=  output and type
     error :=  error)