import { useQuery } from '@tanstack/react-query'
import React, { useContext } from 'react'
import { CompetitionContext } from '../../api/helper/context/competition_context'
import { RegistrationContext } from '../../api/helper/context/registration_context'
import { UserContext } from '../../api/helper/context/user_context'
import { getSingleRegistration } from '../../api/registration/get/get_registrations'
import { setMessage } from '../events/messages'
import LoadingMessage from '../messages/loadingMessage'

export default function RegistrationProvider({ children }) {
  const { user } = useContext(UserContext)
  const loggedIn = user !== null
  const { competitionInfo } = useContext(CompetitionContext)
  const {
    data: registration,
    isLoading,
    isError,
    refetch,
  } = useQuery({
    queryKey: ['registration', competitionInfo.id, user?.id],
    queryFn: () => getSingleRegistration(user?.id, competitionInfo.id),
    refetchOnWindowFocus: false,
    refetchOnReconnect: false,
    staleTime: Infinity,
    refetchOnMount: 'always',
    retry: false,
    onError: (err) => {
      setMessage(err.error, 'error')
    },
    enabled: loggedIn,
  })
  return loggedIn && isLoading ? (
    <LoadingMessage />
  ) : // eslint-disable-next-line unicorn/no-nested-ternary
  isError || !loggedIn ? (
    <RegistrationContext.Provider
      value={{ registration: null, refetch: () => {}, isRegistered: false }}
    >
      {children}
    </RegistrationContext.Provider>
  ) : (
    <RegistrationContext.Provider
      value={{
        registration: registration.registration,
        refetch,
        isRegistered:
          registration?.competing?.registration_status !== undefined,
      }}
    >
      {children}
    </RegistrationContext.Provider>
  )
}
