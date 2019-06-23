open HolKernel Parse boolLib IndDefLib

open testutils

fun checkhyps th = if null (hyp th) then ()
                   else die "FAILED - Hyps in theorem!"

(* set up a fake arithmetic theory *)
val _ = new_type ("num", 0)
val _ = new_constant("Z", ``:num``)
val _ = new_constant("ONE", ``:num``)
val _ = new_constant("TWO", ``:num``)
val _ = new_constant("FOUR", ``:num``)
val _ = new_constant("<=", ``:num -> num -> bool``)
val _ = set_fixity "<=" (Infix(NONASSOC, 450))
val _ = new_constant("<", ``:num -> num -> bool``)
val _ = set_fixity "<" (Infix(NONASSOC, 450))
val _ = new_constant ("+", ``:num -> num -> num``)
val _ = set_fixity "+" (Infixl 500)
val _ = new_constant ("*", ``:num -> num -> num``)
val _ = set_fixity "*" (Infixl 600)
val _ = new_constant ("SUC", ``:num -> num``)


val _ = print "*** Testing inductive definitions - mutual recursion\n"


val (oe_rules, oe_ind, oe_cases) = Hol_reln`
  even Z /\
  (!m. odd m /\ ONE <= m ==> even (m + ONE)) /\
  (!m. even m ==> odd (m + ONE))
`;
val _ = checkhyps oe_rules

val _ = print "*** Testing inductive definitions - scheme variables\n"

val (rtc_rules, rtc_ind, rtc_cases) = Hol_reln`
  (!x. rtc r x x) /\
  (!x y z. rtc r x y /\ r y z ==> rtc r x z)
`;
val _ = checkhyps rtc_rules

val _ = print "*** Testing schematic variables for multiple relations\n"
val (mscheme_rules, mscheme_ind, mscheme_cases) = Hol_reln`
  (!n m. n < m ==> foo P n m) /\
  (!n m. P n ==> foo P n m) /\
  (!n m. bar P n ==> foo P n m) /\
  (!n. FOUR < n ==> bar P (TWO * n))
`
val _ = checkhyps mscheme_rules

val _ = print "*** Testing inductive definitions - existential vars\n"

val (rtc'_rules, rtc'_ind, rtc'_cases) = Hol_reln`
  (!x. rtc' r x x) /\
  (!x y. r x y /\ (?z. rtc' r z y) ==> rtc' r x y)
`;
val _ = checkhyps rtc'_rules

(* emulate the example in examples/opsemScript.sml *)
val _ = print "*** Testing opsem example\n"
val _ = new_type ("comm", 0)
val _ = new_constant("Skip", ``:comm``)
val _ = new_constant("::=", ``:num -> ((num -> num) -> num) -> comm``)
val _ = new_constant(";;", ``:comm -> comm -> comm``)
val _ = new_constant("If", ``:((num -> num) -> bool) -> comm -> comm -> comm``)
val _ = new_constant("While", ``:((num -> num) -> bool) -> comm -> comm``)
val _ = set_fixity "::=" (Infixr 400);
val _ = set_fixity ";;"  (Infixr 350);

val (rules,induction,ecases) = Hol_reln
     `(!s. EVAL Skip s s)
 /\   (!s V E. EVAL (V ::= E) s (\v. if v=V then E s else s v))
 /\   (!C1 C2 s1 s3.
        (?s2. EVAL C1 s1 s2 /\ EVAL C2 s2 s3) ==> EVAL (C1;;C2) s1 s3)
 /\   (!C1 C2 s1 s2 B. EVAL C1 s1 s2 /\  B s1 ==> EVAL (If B C1 C2) s1 s2)
 /\   (!C1 C2 s1 s2 B. EVAL C2 s1 s2 /\ ~B s1 ==> EVAL (If B C1 C2) s1 s2)
 /\   (!C s B.                           ~B s ==> EVAL (While B C) s s)
 /\   (!C s1 s3 B.
        (?s2. EVAL C s1 s2 /\
              EVAL (While B C) s2 s3 /\ B s1) ==> EVAL (While B C) s1 s3)`;

val _ = checkhyps rules

(* check MONO_COND *)
val _ = Hol_reln
`(foo p x x) /\
 ((if p y then foo p y x else foo p y y) ==> foo p x y)`

val _ = tprint "Can still look at rule_induction data"
val _ = if can ThmSetData.current_data{settype = "rule_induction"} then OK()
        else die ""


val _ = tprint "With Unicode should fail"
val _ = if (xHol_reln "tr" `
                      (!x. ▷ x Z) /\
                      (!x y. ▷ (SUC x) (SUC y) ==> ▷ x y)
           ` ; false) handle HOL_ERR _ => true then OK()
        else die "FAILED"

val _ = tprint "Vacuous clause failure"
val _ = if (with_flag (Feedback.emit_ERR, false)
              Hol_reln `(!x. rel x Z) /\ (!x y. rel x y)` ; false)
               handle HOL_ERR {message,...} =>
                      String.isSuffix
                          "Vacuous clause trivialises whole definition"
                          message
        then OK()
        else die "FAILED"

(* isolate_to_front test cases *)
val failcount = ref 0
val _ = diemode := Remember failcount
local
  fun itf_test (nm,t1,t2,result) =
      convtest ("isolate_to_front/" ^ nm,isolate_to_front t1,t2,result)
  val _ = new_constant("csize", “:comm -> num”)
in
val _ = List.app itf_test [(*
  ("simple/univgoal/vars-in-order", “EVAL c s0 s1”,
   “∀d t0 t. EVAL d t0 t ==> EVAL d t t0”,
   “∀d t0 t. EVAL d t0 t ==> EVAL d t t0”),
  ("simple/univgoal/vars-wrong-order", “EVAL c s0 s1”,
   “∀t0 t d. EVAL d t0 t ==> EVAL d t t0”,
   “∀d t0 t. EVAL d t0 t ==> EVAL d t t0”),
  ("simple/specgoal", “EVAL c s0 s1”,
   “EVAL d t0 t ==> EVAL d t t0”,
   “∀d t0 t. EVAL d t0 t ==> EVAL d t t0”),
  ("moving/univgoal/nice-vars", “EVAL c s0 s1”,
   “∀d t0 t1. csize d = ONE ∧ EVAL d t0 t1 ⇒ EVAL d t1 t0”,
   “∀d t0 t1. EVAL d t0 t1 ⇒ (csize d = ONE ⇒ EVAL d t1 t0)”),
  ("moving/univgoal/extra-vars", “EVAL c s0 s1”,
   “∀d n t0 t1 . csize d = n ∧ EVAL d t0 t1 ⇒ EVAL d t1 t0”,
   “∀d t0 t1 . EVAL d t0 t1 ⇒ ∀n. csize d = n ⇒ EVAL d t1 t0”) *)
]
end


val _ = exit_count0 failcount
