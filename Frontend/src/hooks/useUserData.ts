import { useQuery } from '@tanstack/react-query'
import { getUsersInfo } from '../api/user/post/get_user_info'

export function useUserData(ids: number[]) {
  // requires a custom comparator because standard JS interprets everything as strings when sorting:
  // https://typescript-eslint.io/rules/require-array-sort-compare/
  const sortedIds = ids.toSorted((a, b) => a - b)
  return useQuery({
    queryFn: () => getUsersInfo(sortedIds),
    queryKey: ['user-info', ...sortedIds],
    refetchOnWindowFocus: false,
    refetchOnReconnect: false,
    staleTime: Infinity,
    refetchOnMount: 'always',
    retry: false,
  })
}
