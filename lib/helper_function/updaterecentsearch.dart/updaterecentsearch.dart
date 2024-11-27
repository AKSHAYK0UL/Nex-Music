List<String> updateRecentSearch(String searchQuery, List<String> recentSearch) {
  if (recentSearch.contains(searchQuery)) {
    recentSearch.remove(searchQuery);
  }
  recentSearch.add(searchQuery);
  return recentSearch;
}
