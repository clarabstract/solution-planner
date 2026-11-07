# Breakdown criteria

What makes a good breakdown. These are judgement calls, unlike the checks in [the format reference](solution-spec-format.md#checks).

## Each component

1. **Purpose:** one sentence with no "and", plus what it deliberately doesn't do. If you need "and", it's probably two things.
2. **Ownership:** every data item and rule has one owner. If a requirement spans components, each one's `owns` shows its part, because shared rules drift apart.
3. **Rule placement:** judgement calls go in skills. Rules that must hold under concurrency stay with the data, because a caller checking first can't prevent a race.
4. **Contract:** callers use named operations, never internals or another component's data.
5. **Swap test:** replacing it changes only that component and at most one adapter.
6. **Generic test:** to count as reusable, it needs a named second consumer, or an interface with no domain nouns that could be published without mentioning this app. Swappable is the default, because a clean contract costs little. Reusable has to be earned, because speculative reuse produces over-splitting.

## When to split or merge

7. **Split only for a stated reason:**
   - a different data owner
   - a different rate of change
   - no need to change in the same transaction
   - a different trust boundary
   - deterministic versus judgement logic
   - a named second consumer
   - a rule that must hold under concurrency, which has to stay with the data

   A new deployed service is the most expensive boundary to get wrong, so it always needs one of these.
8. **Too big:** it can't be specced in one fresh session from the plan alone, or reviewed in one sitting.
9. **Too small:** it always changes with a neighbour, owns no rule, or just passes calls through.
10. **Order of preference:** `reuse`, then `modify`, then `external`, then `build`. Argue against this order when a change would be bigger than adopting a tool or building new.

## The whole plan

11. **Fewest parts:** the fewest components that pass the above and the checks. Each extra part is more for someone to review and run.
12. **Fits the budget:** `budget` limits the whole spec and its requirement files, not just the component count, because review is the real cost and it's mostly spent on requirements. Keep only what a later stage needs. If the spec won't fit, merge entries, cut scope or question the problem rather than exceeding it.
