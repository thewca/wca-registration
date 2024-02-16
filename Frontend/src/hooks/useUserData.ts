import { useQuery } from '@tanstack/react-query'
import { getCompetitorsInfo } from '../api/user/post/get_user_info'

export function useUserData(ids: number[]) {
  return useQuery({
    queryFn: () => getCompetitorsInfo(ids),
    queryKey: ['user-info', ...ids],
    refetchOnWindowFocus: false,
    refetchOnReconnect: false,
    staleTime: Infinity,
    refetchOnMount: 'always',
    retry: false,
  })
}
