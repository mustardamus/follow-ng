module.exports = (helpers) ->
  Schema = new @Schema
    username:           String
    password:           String
    email:              String
    accounts:           Array
    ### {
      accessToken:        String
      accessTokenSecret:  String
      info:               Object  # received twitter information by GET users/show
      searchTerms:        Array   # search terms associated with the account
    } ###
  ,
    timestamps: true

  @model 'User', Schema
