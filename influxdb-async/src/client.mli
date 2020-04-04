val ping :
  ?port:int -> string -> Influxdb.Protocol.ping_response Async.Deferred.t
(** Ping the host *)

val write :
  ?precision:Influxdb.Precision.t ->
  ?port:int ->
  database:string ->
  points:Influxdb.Point.t list ->
  string ->
  unit Async.Deferred.t
(** Write a list of points to the host supplied *)
