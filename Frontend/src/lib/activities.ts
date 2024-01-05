import { Activity } from '@wca/helpers'

export const earliestWithLongestTieBreaker = (a: Activity, b: Activity) => {
  if (a.startTime < b.startTime) {
    return -1
  }
  if (a.startTime > b.startTime) {
    return 1
  }
  if (a.endTime < b.endTime) {
    return 1
  }
  if (a.endTime > b.endTime) {
    return -1
  }
  return 0
}

// assumes they are sorted
export const groupActivities = (activities: Activity[]) => {
  const grouped: Activity[][] = []
  activities.forEach((activity) => {
    if (
      grouped.length > 0 &&
      areGroupable(activity, grouped[grouped.length - 1][0])
    ) {
      grouped[grouped.length - 1].push(activity)
    } else {
      grouped.push([activity])
    }
  })
  return grouped
}

const areGroupable = (a: Activity, b: Activity) => {
  return (
    a.startTime === b.startTime &&
    a.endTime === b.endTime &&
    a.activityCode === b.activityCode
  )
}

export const getActivityEvent = (activity: Activity) => {
  return activity.activityCode.split('-')[0]
}

export const getActivityRoundId = (activity: Activity) => {
  return activity.activityCode.split('-').slice(0, 2).join('-')
}
