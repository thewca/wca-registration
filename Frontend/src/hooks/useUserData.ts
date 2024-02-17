import { useQuery } from '@tanstack/react-query'
import { getUsersInfo } from '../api/user/post/get_user_info'

export function useUserData(ids: number[]) {
  const sortedIds = ids.sort((a, b) => a - b)
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
