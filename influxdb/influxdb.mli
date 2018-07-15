module Precision : sig
  type t =
    | Nanosecond
    | Microsecond
    | Millisecond
    | Second
    | Minute 
    | Hour

  val to_string : t -> string
  val of_string : string -> t option
end

module TimestampNS : sig
  type t = int64
  val of_float_seconds : float -> t
  val to_string_precision : Precision.t -> t -> string
end

module Field : sig
  type field_key = string
  type field_value =
    | Float of float
    | Int of int
    | String of string
    | Bool of bool

  type t = (field_key * field_value)

  val v_to_string : field_value -> string
  val to_string : t -> string
  val float : string -> float -> t
  val int : string -> int -> t
  val string : string -> string -> t
  val bool : string -> bool -> t
end

module Point : sig 
  type t = {
    name : string;
    field : Field.t;
    tags : (string * string) list;
    extra_fields : Field.t list;
    (* If None, a timestamp will be assigned by InfluxDB  *)
    timestamp_ns : TimestampNS.t option;
  }

  val to_line : ?precision:Precision.t -> t -> string
  val create : ?tags:(string * string) list -> ?extra_fields:Field.t list -> ?timestamp_ns:TimestampNS.t -> field:Field.t -> string -> t
end