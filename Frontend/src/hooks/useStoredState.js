import { useState } from 'react'

/*
 * Only works for strings as-is, but can use JSON.parse and JSON.stringify
 * to generalize it.
 */

/**
 * This functions like the useState hook, but it fetches the state stored in
 * local storage, via the given key, on subsequent uses.
 */
export function useStoredState(initialState, key) {
  const storedState = localStorage.getItem(key)

  const [state, setState] = useState(() => {
    if (storedState === null) {
      localStorage.setItem(key, initialState)
      return initialState
    }
    return storedState
  })

  function setAndStoreState(newState) {
    setState(newState)
    localStorage.setItem(key, newState)
  }

  return [state, setAndStoreState]
}
