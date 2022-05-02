import 'dart:ui';

import 'package:latlong2/latlong.dart';
import 'dart:math';
import 'package:country_codes/country_codes.dart';
import '../variablen/locale.dart' as locales;

//------------------------------
// Datenmodell für ein Land
//------------------------------
class Country {
  //------------------------------
  // Eigenschaften und Konstruktor
  //------------------------------
  String name;
  String short;
  LatLng coords;
  //Coords mapCoords;
  double area;

  String Introduction_Background_text;
  String Geography_Location_text;
  String Geography_Mapreferences_text;
  String Geography_Area_total_text;
  String Geography_Area_land_text;
  String Geography_Area_water_text;
  String Geography_Landboundaries_total_text;
  String Geography_Landboundaries_bordercountries_text;
  String Geography_Coastline_text;
  String Geography_Climate_text;
  String Geography_Terrain_text;
  String Geography_Elevation_meanelevation_text;
  String Geography_Elevation_highestpoint_text;
  String Geography_Elevation_lowestpoint_text;
  String Geography_Naturalresources_text;
  String Geography_Landuse_agriculturalland_text;
  String Geography_Landuse_agriculturalland_arableland_text;
  String Geography_Landuse_agriculturalland_permanentcrops_text;
  String Geography_Landuse_agriculturalland_permanentpasture_text;
  String Geography_Landuse_forest_text;
  String Geography_Landuse_other_text;
  String Geography_Irrigatedland_text;
  String Geography_Populationdistribution_text;
  String Geography_Naturalhazards_text;
  String Geography_Geography_note_text;
  String PeopleandSociety_Population_text;
  String PeopleandSociety_Nationality_noun_text;
  String PeopleandSociety_Ethnicgroups_text;
  String PeopleandSociety_Languages_text;
  String PeopleandSociety_Religions_text;
  String PeopleandSociety_Medianage_total_text;
  String PeopleandSociety_Medianage_male_text;
  String PeopleandSociety_Medianage_female_text;
  String PeopleandSociety_Populationgrowthrate_text;
  String PeopleandSociety_Birthrate_text;
  String PeopleandSociety_Deathrate_text;
  String PeopleandSociety_Netmigrationrate_text;
  String PeopleandSociety_Populationdistribution_text;
  String PeopleandSociety_Urbanization_urbanpopulation_text;
  String PeopleandSociety_Majorurbanareas_population_text;
  String PeopleandSociety_Sexratio_totalpopulation_text;
  String PeopleandSociety_Mothersmeanageatfirstbirth_text;
  String PeopleandSociety_Infantmortalityrate_total_text;
  String PeopleandSociety_Lifeexpectancyatbirth_totalpopulation_text;
  String PeopleandSociety_Totalfertilityrate_text;
  String PeopleandSociety_Contraceptiveprevalencerate_text;
  String PeopleandSociety_Drinkingwatersource_improved_urban_text;
  String PeopleandSociety_Drinkingwatersource_improved_rural_text;
  String PeopleandSociety_Physiciansdensity_text;
  String PeopleandSociety_Hospitalbeddensity_text;
  String PeopleandSociety_Sanitationfacilityaccess_improved_urban_text;
  String PeopleandSociety_HIV_AIDS_peoplelivingwithHIV_AIDS_text;
  String PeopleandSociety_HIV_AIDS_deaths_text;
  String PeopleandSociety_HIV_AIDS_adultprevalencerate_text;
  String PeopleandSociety_Childrenundertheageof5yearsunderweight_text;
  String PeopleandSociety_Educationexpenditures_text;
  String PeopleandSociety_Schoollifeexpectancy_primarytotertiaryeducation__total_text;
  String PeopleandSociety_Unemployment_youthages15_24_total_text;
  String Environment_Environment_currentissues_text;
  String Environment_Environmentagreements_partyto_text;
  String Environment_Airpollutants_particulatematteremissions_text;
  String Environment_Airpollutants_carbondioxideemissions_text;
  String Environment_Airpollutants_methaneemissions_text;
  String Environment_Climate_text;
  String Environment_Wasteandrecycling_municipalsolidwastegeneratedannually_text;
  String Environment_Wasteandrecycling_municipalsolidwasterecycledannually_text;
  String Environment_Wasteandrecycling_percentofmunicipalsolidwasterecycled_text;
  String Government_Countryname_conventionallongform_text;
  String Government_Countryname_conventionalshortform_text;
  String Government_Countryname_etymology_text;
  String Government_Governmenttype_text;
  String Government_Capital_name_text;
  String Government_Capital_geographiccoordinates_text;
  String Government_Capital_etymology_text;
  String Government_Administrativedivisions_text;
  String Government_Independence_text;
  String Government_Nationalholiday_text;
  String Government_Constitution_history_text;
  String Government_Legalsystem_text;
  String Government_Suffrage_text;
  String Government_Executivebranch_headofgovernment_text;
  String Government_Politicalpartiesandleaders_text;
  String Government_Internationalorganizationparticipation_text;
  String Government_Flagdescription_text;
  String Government_Nationalsymbol_s__text;
  String Economy_Economicoverview_text;
  String Economy_RealGDP_purchasingpowerparity__RealGDP_purchasingpowerparity_2020_text;
  String Economy_RealGDPgrowthrate_RealGDPgrowthrate2020_text;
  String Economy_RealGDPpercapita_RealGDPpercapita2020_text;
  String Energy_Electricityaccess_electrification_totalpopulation_text;
  String Energy_Electricity_production_text;
  String Energy_Electricity_consumption_text;
  String Transportation_Roadways_total_text;
  String Communications_Internetusers_total_text;
  String Communications_Internetusers_percentofpopulation_text;
  String TransnationalIssues_Illicitdrugs_text;

  Country(
    this.name,
    this.coords,
    this.short,
    this.area,
    this.Introduction_Background_text,
    this.Geography_Location_text,
    this.Geography_Mapreferences_text,
    this.Geography_Area_total_text,
    this.Geography_Area_land_text,
    this.Geography_Area_water_text,
    this.Geography_Landboundaries_total_text,
    this.Geography_Landboundaries_bordercountries_text,
    this.Geography_Coastline_text,
    this.Geography_Climate_text,
    this.Geography_Terrain_text,
    this.Geography_Elevation_meanelevation_text,
    this.Geography_Elevation_highestpoint_text,
    this.Geography_Elevation_lowestpoint_text,
    this.Geography_Naturalresources_text,
    this.Geography_Landuse_agriculturalland_text,
    this.Geography_Landuse_agriculturalland_arableland_text,
    this.Geography_Landuse_agriculturalland_permanentcrops_text,
    this.Geography_Landuse_agriculturalland_permanentpasture_text,
    this.Geography_Landuse_forest_text,
    this.Geography_Landuse_other_text,
    this.Geography_Irrigatedland_text,
    this.Geography_Populationdistribution_text,
    this.Geography_Naturalhazards_text,
    this.Geography_Geography_note_text,
    this.PeopleandSociety_Population_text,
    this.PeopleandSociety_Nationality_noun_text,
    this.PeopleandSociety_Ethnicgroups_text,
    this.PeopleandSociety_Languages_text,
    this.PeopleandSociety_Religions_text,
    this.PeopleandSociety_Medianage_total_text,
    this.PeopleandSociety_Medianage_male_text,
    this.PeopleandSociety_Medianage_female_text,
    this.PeopleandSociety_Populationgrowthrate_text,
    this.PeopleandSociety_Birthrate_text,
    this.PeopleandSociety_Deathrate_text,
    this.PeopleandSociety_Netmigrationrate_text,
    this.PeopleandSociety_Populationdistribution_text,
    this.PeopleandSociety_Urbanization_urbanpopulation_text,
    this.PeopleandSociety_Majorurbanareas_population_text,
    this.PeopleandSociety_Sexratio_totalpopulation_text,
    this.PeopleandSociety_Mothersmeanageatfirstbirth_text,
    this.PeopleandSociety_Infantmortalityrate_total_text,
    this.PeopleandSociety_Lifeexpectancyatbirth_totalpopulation_text,
    this.PeopleandSociety_Totalfertilityrate_text,
    this.PeopleandSociety_Contraceptiveprevalencerate_text,
    this.PeopleandSociety_Drinkingwatersource_improved_urban_text,
    this.PeopleandSociety_Drinkingwatersource_improved_rural_text,
    this.PeopleandSociety_Physiciansdensity_text,
    this.PeopleandSociety_Hospitalbeddensity_text,
    this.PeopleandSociety_Sanitationfacilityaccess_improved_urban_text,
    this.PeopleandSociety_HIV_AIDS_peoplelivingwithHIV_AIDS_text,
    this.PeopleandSociety_HIV_AIDS_deaths_text,
    this.PeopleandSociety_HIV_AIDS_adultprevalencerate_text,
    this.PeopleandSociety_Childrenundertheageof5yearsunderweight_text,
    this.PeopleandSociety_Educationexpenditures_text,
    this.PeopleandSociety_Schoollifeexpectancy_primarytotertiaryeducation__total_text,
    this.PeopleandSociety_Unemployment_youthages15_24_total_text,
    this.Environment_Environment_currentissues_text,
    this.Environment_Environmentagreements_partyto_text,
    this.Environment_Airpollutants_particulatematteremissions_text,
    this.Environment_Airpollutants_carbondioxideemissions_text,
    this.Environment_Airpollutants_methaneemissions_text,
    this.Environment_Climate_text,
    this.Environment_Wasteandrecycling_municipalsolidwastegeneratedannually_text,
    this.Environment_Wasteandrecycling_municipalsolidwasterecycledannually_text,
    this.Environment_Wasteandrecycling_percentofmunicipalsolidwasterecycled_text,
    this.Government_Countryname_conventionallongform_text,
    this.Government_Countryname_conventionalshortform_text,
    this.Government_Countryname_etymology_text,
    this.Government_Governmenttype_text,
    this.Government_Capital_name_text,
    this.Government_Capital_geographiccoordinates_text,
    this.Government_Capital_etymology_text,
    this.Government_Administrativedivisions_text,
    this.Government_Independence_text,
    this.Government_Nationalholiday_text,
    this.Government_Constitution_history_text,
    this.Government_Legalsystem_text,
    this.Government_Suffrage_text,
    this.Government_Executivebranch_headofgovernment_text,
    this.Government_Politicalpartiesandleaders_text,
    this.Government_Internationalorganizationparticipation_text,
    this.Government_Flagdescription_text,
    this.Government_Nationalsymbol_s__text,
    this.Economy_Economicoverview_text,
    this.Economy_RealGDP_purchasingpowerparity__RealGDP_purchasingpowerparity_2020_text,
    this.Economy_RealGDPgrowthrate_RealGDPgrowthrate2020_text,
    this.Economy_RealGDPpercapita_RealGDPpercapita2020_text,
    this.Energy_Electricityaccess_electrification_totalpopulation_text,
    this.Energy_Electricity_production_text,
    this.Energy_Electricity_consumption_text,
    this.Transportation_Roadways_total_text,
    this.Communications_Internetusers_total_text,
    this.Communications_Internetusers_percentofpopulation_text,
    this.TransnationalIssues_Illicitdrugs_text
  );

  //-------------------------------
  // ermöglicht Init aus JSON
  //  benötigt bereits decoded-JSON
  //-------------------------------
  factory Country.fromJSON(dynamic json) {
    List coords = List.from(json['latlng']);

    String? acc3 = locales.locale;

    acc3Conv() async {
      acc3 = acc3?.toUpperCase();

      switch(acc3) {
        case "DE":
          acc3 = "deu";
          break;
        case "CS":
          acc3 = "ces";
          break;
        case "ET":
          acc3 = "est";
          break;
        case "FI":
          acc3 = "fin";
          break;
        case "FR":
          acc3 = "fra";
          break;
        case "HR":
          acc3 = "hrv";
          break;
        case "HU":
          acc3 = "hun";
          break;
        case "IT":
          acc3 = "ita";
          break;
        case "JA":
          acc3 = "jpn";
          break;
        case "KO":
          acc3 = "kor";
          break;
        case "NL":
          acc3 = "nld";
          break;
        case "FA":
          acc3 = "per";
          break;
        case "PL":
          acc3 = "pol";
          break;
        case "PT":
          acc3 = "por";
          break;
        case "RU":
          acc3 = "rus";
          break;
        case "SK":
          acc3 = "slk";
          break;
        case "SV":
          acc3 = "swe";
          break;
        case "ES":
          acc3 = "spa";
          break;
        case "UR":
          acc3 = "urd";
          break;
        case "ZH":
          acc3 = "zho";
          break;
        default:
          acc3 = "eng";
      }
      //print(acc3);
    }
    acc3Conv();
    print(locales.locale);

    Country land;

    if (acc3 == "eng") {
      land = Country(json['name']['common'] as String,
          LatLng(coords[0].toDouble(), coords[1].toDouble()),
          json['cca2'].toLowerCase() as String,
          json['area']);
    } else {
      land = Country(json['translations'][acc3]['common'] as String,
          LatLng(coords[0].toDouble(), coords[1].toDouble()),
          json['cca2'].toLowerCase() as String,
          json['area'].toDouble(),
          json['facts'][0],
          json['facts'][1],
          json['facts'][2],
          json['facts'][3],
          json['facts'][4],
          json['facts'][5],
          json['facts'][6],
          json['facts'][7],
          json['facts'][8],
          json['facts'][9],
          json['facts'][10],
          json['facts'][11],
          json['facts'][12],
          json['facts'][13],
          json['facts'][14],
          json['facts'][15],
          json['facts'][16],
          json['facts'][17],
          json['facts'][18],
          json['facts'][19],
          json['facts'][20],
          json['facts'][21],
          json['facts'][22],
          json['facts'][23],
          json['facts'][24],
          json['facts'][25],
          json['facts'][26],
          json['facts'][27],
          json['facts'][28],
          json['facts'][29],
          json['facts'][30],
          json['facts'][31],
          json['facts'][32],
          json['facts'][33],
          json['facts'][34],
          json['facts'][35],
          json['facts'][36],
          json['facts'][37],
          json['facts'][38],
          json['facts'][39],
          json['facts'][40],
          json['facts'][41],
          json['facts'][42],
          json['facts'][43],
          json['facts'][44],
          json['facts'][45],
          json['facts'][46],
          json['facts'][47],
          json['facts'][48],
          json['facts'][49],
          json['facts'][50],
          json['facts'][51],
          json['facts'][52],
          json['facts'][53],
          json['facts'][54],
          json['facts'][55],
          json['facts'][56],
          json['facts'][57],
          json['facts'][58],
          json['facts'][59],
          json['facts'][60],
          json['facts'][61],
          json['facts'][62],
          json['facts'][63],
          json['facts'][64],
          json['facts'][65],
          json['facts'][66],
          json['facts'][67],
          json['facts'][68],
          json['facts'][69],
          json['facts'][70],
          json['facts'][71],
          json['facts'][72],
          json['facts'][73],
          json['facts'][74],
          json['facts'][75],
          json['facts'][76],
          json['facts'][77],
          json['facts'][78],
          json['facts'][79],
          json['facts'][80],
          json['facts'][81],
          json['facts'][82],
          json['facts'][83],
          json['facts'][84],
          json['facts'][85],
          json['facts'][86],
          json['facts'][87],
          json['facts'][88],
          json['facts'][89],
          json['facts'][90],
          json['facts'][91],
          json['facts'][92],
          json['facts'][93],
          json['facts'][94],
          json['facts'][95],
        );
    }


    return land;
  }

  /*static Coords mapProjection(LatLng mapCoords) {
    double lat = mapCoords.latitude;
    double long = mapCoords.longitude;
    double mapWidth = 40075;
    double mapHeight = 10002 * 2;

    double x = (long + 180) * (mapWidth / 360);
    double latRad = lat * pi / 180;

    double mercN = log(tan((pi / 4) + (latRad / 2)));
    double y = (mapHeight / 2) - (mapWidth * mercN / (2 * pi));

    return Coords(x, y);
  }*/

  // not really useable
  double mapDistance(LatLng other) {
    return sqrt(pow((coords.latitude - other.latitude), 2) +
        pow((coords.longitude - other.longitude), 2));
  }

  double mapDirection(LatLng other) {
    double w = other.latitude - coords.latitude;
    double h = other.longitude - coords.longitude;

    double atanCalc = atan(h / w);
    if (w < 0 || h < 0) atanCalc += pi;
    if (w > 0 && h < 0) atanCalc -= pi;
    if (atanCalc < 0) atanCalc += 2 * pi;

    return (atanCalc % (2 * pi));
  }

  //------------------------------
  // Distanzberechnung über Coords
  // und anderes Land
  //------------------------------
  double getDistanceByCoords(LatLng other) {
    return const Distance().as(LengthUnit.Kilometer, coords, other);
  }

  double getDistanceByCountry(Country other) {
    return const Distance().as(LengthUnit.Kilometer, coords, other.coords);
  }

  //-----------------------------------
  // Funtkionen zur Richtungsberechnung
  //  Ergebnis in Rad,
  //  Icon-Drehungen benötigen auch Rad
  //-----------------------------------

  double toRadian(double input) {
    return input * pi / 180;
  }

  LatLng transformPoint(LatLng point) {
    return LatLng(toRadian(point.latitude), toRadian(point.longitude));
  }

  // starting from this country, which direction should be taken?
  double getInitialBearing(LatLng other) {
    LatLng transformedOther = transformPoint(other);
    LatLng transformedSelf = transformPoint(coords);

    double x = sin(transformedOther.longitude - transformedSelf.longitude) *
        cos(transformedOther.latitude);
    double y = cos(transformedSelf.latitude) * sin(transformedOther.latitude) -
        sin(transformedSelf.latitude) *
            cos(transformedOther.latitude) *
            cos(transformedOther.longitude - transformedSelf.longitude);
    return atan2(x, y);
  }

  @override
  String toString() {
    return '{ $name, $coords}';
  }
}
