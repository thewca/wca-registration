export const earliestWithLongestTieBreaker = (a, b) => {
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
export const groupActivities = (activities) => {
  const grouped = []
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

export const areGroupable = (act1, act2) => {
  return (
    act1.startTime === act2.startTime &&
    act1.endTime === act2.endTime &&
    act1.activityCode === act2.activityCode
  )
}
