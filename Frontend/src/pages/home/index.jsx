import React, { useContext } from 'react'
import { CompetitionContext } from '../../api/helper/context/competition_context'
import styles from './home.module.scss'

export default function HomePage() {
  const { competitionInfo } = useContext(CompetitionContext)
  return (
    <div className={styles.homeContainer}>
      <div className={styles.information}>
        <h2>Information:</h2>
        <span>
          Welcome to {competitionInfo.name}, the ultimate destination for
          Rubik's Cube enthusiasts! Whether you're a seasoned speedcuber or a
          beginner looking to unravel the mysteries of the cube,{' '}
          {competitionInfo.short_name} has something exciting in store for you.
          Prepare to dive into the world of twists, turns, and mind-boggling
          algorithms! Join us on{' '}
          {new Date(competitionInfo.start_date).toDateString()} in{' '}
          {competitionInfo.city} as we bring together the most talented cubers
          from around the globe for an unforgettable competition experience.
          Push your solving skills to the limit, compete against the best, and
          bask in the exhilaration of record-breaking moments. With various
          categories and events, {competitionInfo.short_name} caters to cubers
          of all skill levels. From the lightning-fast speeds of the 3x3x3
          Rubik's Cube to the intricate patterns of the Megaminx, there's a
          challenge waiting for every cuber. Don't miss out on the Pyraminx,
          Square-1, and a range of other exciting puzzles that will keep you on
          the edge of your seat. Immerse yourself in the vibrant atmosphere of
          our venue, filled with like-minded cubers sharing their love for the
          iconic Rubik's Cube. Whether you're spectating or participating,{' '}
          {competitionInfo.short_name} offers an opportunity to connect with
          fellow cubing enthusiasts, exchange strategies, and witness the sheer
          brilliance of top cubers in action. To ensure fair competition, our
          experienced delegates oversee every solve, guaranteeing accuracy and
          integrity throughout the event. Get ready to break records, challenge
          yourself, and maybe even discover new techniques to solve the cube
          faster than ever before. Can't wait to get started? Register today and
          secure your spot at {competitionInfo.name}! Limited slots are
          available, so don't miss this chance to be a part of the most
          anticipated Rubik's Cube competition of the year. Whether you're here
          to compete or simply soak up the excitement,{' '}
          {competitionInfo.short_name} promises an unforgettable experience for
          everyone.
        </span>
      </div>
      <div className={styles.registrationPeriod}>
        <h2>Registration Period:</h2>
        Online registration opened{' '}
        {new Date(competitionInfo.registration_open).toString()} and will close{' '}
        {new Date(competitionInfo.registration_close).toString()}.
      </div>
    </div>
  )
}
