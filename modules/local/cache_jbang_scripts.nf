process CACHE_JBANG_SCRIPTS {

  input:
    path regenie_pattern_search_java

  output:
    path "RegeniePatternSearch.jar", emit: regenie_pattern_search_jar

  """
  jbang export portable -O=RegeniePatternSearch.jar ${regenie_pattern_search_java}
  """

}
