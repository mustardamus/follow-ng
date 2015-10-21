module.exports = (helpers) ->
  Schema = new @Schema
    userId:       @Schema.ObjectId  # to which user does the potential friend belong
    accountId:    @Schema.ObjectId  # to which account does the friend belong
    info:         Object            # the twitter info of the user
    sourceWorker: String            # name of the worker who has found the friend (eg "search")
    sourceModel:  String            # the model the worker used to find the friend (eg "term")
    sourceId:     @Schema.ObjectId  # the id of the source model
    followed:     Boolean           # has the friend been already followed
    unfollowed:   Boolean           # has the fiend been followed, and then unfollowed
    backfollowed: Boolean           # account is following friend, friend is following account
    followedDate: Date              # when was the account followed
  ,
    timestamps: true

  @model 'Friend', Schema
