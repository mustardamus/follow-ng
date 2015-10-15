module.exports = (helpers) ->
  Schema = new @Schema
    username:           String
    password:           String
    email:              String
    accounts:           Array
    ### {
      accessToken:        String
      accessTokenSecret:  String
    } ###
  ,
    timestamps: true

  @model 'User', Schema
