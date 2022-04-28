import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:woerldle/models/country.dart';
import 'package:flutter_svg/flutter_svg.dart';


class CountryMarker extends Marker {
  CountryMarker({required this.country, required container})
      : super(
          anchorPos: AnchorPos.align(AnchorAlign.top),
          height: 40,
          width: 40,
          point: country.coords,
          builder: (BuildContext cty) => container,
        );

  final Country country;
}

class CountryPopup extends StatelessWidget {
  const CountryPopup({Key? key, required this.country}) : super(key: key);
  final Country country;

  @override
  Widget build(BuildContext context) {
    TextTheme theme = Theme.of(context).textTheme;
    return Card(
      elevation: 30,
      margin: const EdgeInsets.all(20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(10),
        //clipBehavior: Clip.antiAlias,
        children: <Widget>[
          Text("Fact", style: theme.titleLarge, textAlign: TextAlign.left),
          const Divider(color: Colors.black, thickness: 1),
          Text("Introduction:", style: theme.bodyLarge),
          Text(country.Introduction_Background_text),
          const Divider(color: Colors.black, thickness: 1),
          Text("Government:", style: theme.bodyLarge),
          Text(country.Government_Countryname_conventionallongform_text + " is also called " + country.Government_Countryname_conventionalshortform_text + ". The etymology:"),
          Text(country.Government_Countryname_etymology_text),
          Text('\nGovernmenttype: ' + country.Government_Governmenttype_text),
          Text('\n\nThe capital: ' + country.Government_Capital_name_text),
          Text('\nThe etymology: ' + country.Government_Capital_etymology_text),
          Text('\n\nThe independentcy was on' + country.Government_Independence_text),
          Text('\nNationalholiday: ' + country.Government_Nationalholiday_text),
          Text('\nSuffrage: ' + country.Government_Suffrage_text),
          const Divider(color: Colors.black, thickness: 1),
          Text("Geography:", style: theme.bodyLarge),
          Text("\nLocation: " + country.Geography_Location_text),
          Text("\nMap: " + country.Geography_Mapreferences_text),
          Text("\nArea: " + country.Geography_Area_total_text + " of which " + country.Geography_Area_land_text + " is land and " + country.Geography_Area_water_text + " is water"),
          Text(country.Geography_Climate_text + "\n\n"),
          const Divider(color: Colors.black, thickness: 1),
          Text("\nPeople and Security:", style: theme.bodyLarge),
          Text("\nPopulation: " + country.PeopleandSociety_Population_text + " with the growthrate " + country.PeopleandSociety_Populationgrowthrate_text + " and the birthrate of " + country.PeopleandSociety_Birthrate_text),
          Text("\nNationality: " + country.PeopleandSociety_Nationality_noun_text),
          Text("\nEthnicgroups: " + country.PeopleandSociety_Ethnicgroups_text),
          Text("\nLanguages: " + country.PeopleandSociety_Languages_text),
          Text("\nReligions: " + country.PeopleandSociety_Religions_text),
          Text("\nMedianage: " + country.PeopleandSociety_Medianage_total_text + " at total and female: " + country.PeopleandSociety_Medianage_female_text + " male: " + country.PeopleandSociety_Medianage_male_text),
        ]
      ),
    );
  }
}
