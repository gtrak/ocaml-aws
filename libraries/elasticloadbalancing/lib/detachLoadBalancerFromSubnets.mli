open Types
type input = DetachLoadBalancerFromSubnetsInput.t
type output = DetachLoadBalancerFromSubnetsOutput.t
type error = Errors.t
include
  (Aws.Call with type  input :=  input and type  output :=  output and type
     error :=  error)