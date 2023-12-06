const BOOKMARK_KEY = 'bookmarked'

export const getBookmarkedMock = () => {
  return JSON.parse(localStorage.getItem(BOOKMARK_KEY) ?? '[]')
}

export const addBookmarkedMock = (competitionId: string) => {
  const bookmarks = getBookmarkedMock()
  bookmarks.push(competitionId)
  localStorage.setItem(BOOKMARK_KEY, JSON.stringify(bookmarks))
  return true
}

export const removeBookmarkedMock = (competitionId: string) => {
  const bookmarks = getBookmarkedMock()
  localStorage.setItem(
    BOOKMARK_KEY,
    JSON.stringify(bookmarks.filter((c: string) => competitionId !== c))
  )
  return true
}
