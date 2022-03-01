class Serialization {
  //static final Gson gson = new Gson();
  // TODO find replacement
  static void Serialize() {
    /*Preferences.setPreference("data", gson.toJson(Manager.years));
        Preferences.setPreference("default_data", gson.toJson(Manager.termTemplate));*/
  }

  static void Deserialize() {
    /*if (Preferences.existsPreference("data")) {
            Manager.years = gson.fromJson(Preferences.getPreference("data", ""), new TypeToken<ArrayList<Year>>() {
            }.getType());

            Manager.termTemplate = gson.fromJson(Preferences.getPreference("default_data", ""), new TypeToken<ArrayList<Subject>>() {
            }.getType());


        }*/
  }
}
