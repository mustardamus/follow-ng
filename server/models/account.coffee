module.exports = (helpers) ->
  Schema = new @Schema
    userId:            @Schema.ObjectId  # to which user belongs the account
    info:              Object            # all twitter informations
    accessToken:       String            # received when adding account
    accessTokenSecret: String            # --"--
  ,
    timestamps: true

  @model 'Account', Schema
