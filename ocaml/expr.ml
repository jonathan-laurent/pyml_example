open Base

type binop = Add | Mul

type expr =
  | Const of int
  | Binop of expr * binop * expr

let rec eval = function
  | Const n -> n
  | Binop (lhs, Add, rhs) -> eval lhs + eval rhs
  | Binop (lhs, Mul, rhs) -> eval lhs * eval rhs

let rec random_expr n =
  if n <= 0 then
    Const (Random.int 5)
  else
    let op = if Random.bool () then Add else Mul in
    Binop (random_expr (n-1), op, random_expr (n-1))
