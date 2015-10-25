module.exports = (helpers) ->
  Schema = new @Schema
    userId:            @Schema.ObjectId  # to which user belongs the account
    info:              Object            # all twitter informations
    accessToken:       String            # received when adding account
    accessTokenSecret: String            # --"--
    settings:          Object            # settings for the account
    # unfollowInitialFriends: Boolean    # unfollow friends that were there before using follow-ng
    # maxFollowsPerDay:       Number     # how many people to follow per day
    # maxUnfollowsPerDay:     Number     # how many friends to unfollow per day
    # refollowPeriodDay:      Number     # how many days to give followed people to follow back
    hits:              Object            # monitor the follows and unfollows
    # follows:   Number                  # how many follow requests has been sent
    # unfollows: Number                  # how many unfollow requests has been sent
  ,
    timestamps: true

  @model 'Account', Schema
