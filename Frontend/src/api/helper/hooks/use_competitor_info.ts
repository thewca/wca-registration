import { useEffect, useState } from 'react'
import getCompetitorInfo, { CompetitorInfo } from '../../user/get/get_user_info'

export default function useCompetitorInfo(userId: string) {
  const [isLoading, setIsLoading] = useState<boolean>(true)
  const [competitorInfo, setCompetitorInfo] = useState<CompetitorInfo | object>(
    {}
  )

  useEffect(() => {
    getCompetitorInfo(userId).then((competitorInfo) => {
      setCompetitorInfo(competitorInfo)
      setIsLoading(false)
    })
  }, [userId])

  return { isLoading, competitorInfo }
}
