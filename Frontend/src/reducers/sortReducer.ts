type Direction = 'ascending' | 'descending'
interface SortAction {
  type: string
  sortColumn: string
  sortDirection: Direction
}

export function createSortReducer<
  T extends {
    sortColumn: string
    sortDirection: Direction
  },
>(columns: string[]): (state: T, action: SortAction) => T {
  return (state: T, action: SortAction) => {
    if (action.type === 'CHANGE_SORT') {
      if (state.sortColumn === action.sortColumn) {
        return {
          ...state,
          sortDirection:
            state.sortDirection === 'ascending' ? 'descending' : 'ascending',
        } as T
      }
      if (!columns.includes(action.sortColumn)) {
        throw new Error('Unknown Column')
      }
      return {
        sortColumn: action.sortColumn,
        sortDirection: 'ascending',
      } as T
    }
    throw new Error('Unknown Action')
  }
}
