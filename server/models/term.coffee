module.exports = (helpers) ->
  Schema = new @Schema
    userId:       @Schema.ObjectId  # to which user does the term belongs
    accountId:    @Schema.ObjectId  # to which account belongs the term
    term:         String            # the actual search term
    since_id_str: String            # id of last found tweet with the term
  ,
    timestamps: true

  @model 'Term', Schema
