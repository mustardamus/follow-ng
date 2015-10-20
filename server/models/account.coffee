module.exports = (helpers) ->
  Schema = new @Schema
    userId:            @Schema.ObjectId  # to which user belongs the account
    info:              Object            # all twitter informations
    accessToken:       String            # received when adding account
    accessTokenSecret: String            # --"--
    settings:          Object            # settings for the account
    # unfollowInitialFriends: Boolean    # unfollow friends that were there before using follow-ng
  ,
    timestamps: true

  @model 'Account', Schema
