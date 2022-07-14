/*
 * Copyright 2022 XXIV
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
module audiodb;

import std.stdio;
import std.string: strip;
import std.format: format;
import std.net.curl: byLineAsync, CurlException;
import std.uri: encode;
import std.json: JSONValue, parseJSON, JSONException, JSONType;

struct Artist {
    string idArtist;
    string strArtist;
    string strArtistStripped;
    string strArtistAlternate;
    string strLabel;
    string idLabel;
    string intFormedYear;
    string intBornYear;
    string intDiedYear;
    string strDisbanded;
    string strStyle;
    string strGenre;
    string strMood;
    string strWebsite;
    string strFacebook;
    string strTwitter;
    string strBiographyEN;
    string strBiographyDE;
    string strBiographyFR;
    string strBiographyCN;
    string strBiographyIT;
    string strBiographyJP;
    string strBiographyRU;
    string strBiographyES;
    string strBiographyPT;
    string strBiographySE;
    string strBiographyNL;
    string strBiographyHU;
    string strBiographyNO;
    string strBiographyIL;
    string strBiographyPL;
    string strGender;
    string intMembers;
    string strCountry;
    string strCountryCode;
    string strArtistThumb;
    string strArtistLogo;
    string strArtistCutout;
    string strArtistClearart;
    string strArtistWideThumb;
    string strArtistFanart;
    string strArtistFanart2;
    string strArtistFanart3;
    string strArtistFanart4;
    string strArtistBanner;
    string strMusicBrainzID;
    string strISNIcode;
    string strLastFMChart;
    string intCharted;
    string strLocked;
}

struct Discography
{
    string strAlbum;
    string intYearReleased;
}

struct Album
{
    string idAlbum;
    string idArtist;
    string idLabel;
    string strAlbum;
    string strAlbumStripped;
    string strArtist;
    string strArtistStripped;
    string intYearReleased;
    string strStyle;
    string strGenre;
    string strLabel;
    string strReleaseFormat;
    string intSales;
    string strAlbumThumb;
    string strAlbumThumbHQ;
    string strAlbumThumbBack;
    string strAlbumCDart;
    string strAlbumSpine;
    string strAlbum3DCase;
    string strAlbum3DFlat;
    string strAlbum3DFace;
    string strAlbum3DThumb;
    string strDescriptionEN;
    string strDescriptionDE;
    string strDescriptionFR;
    string strDescriptionCN;
    string strDescriptionIT;
    string strDescriptionJP;
    string strDescriptionRU;
    string strDescriptionES;
    string strDescriptionPT;
    string strDescriptionSE;
    string strDescriptionNL;
    string strDescriptionHU;
    string strDescriptionNO;
    string strDescriptionIL;
    string strDescriptionPL;
    string intLoved;
    string intScore;
    string intScoreVotes;
    string strReview;
    string strMood;
    string strTheme;
    string strSpeed;
    string strLocation;
    string strMusicBrainzID;
    string strMusicBrainzArtistID;
    string strAllMusicID;
    string strBBCReviewID;
    string strRateYourMusicID;
    string strDiscogsID;
    string strWikidataID;
    string strWikipediaID;
    string strGeniusID;
    string strLyricWikiID;
    string strMusicMozID;
    string strItunesID;
    string strAmazonID;
    string strLocked;
}

struct Track
{
    string idTrack;
    string idAlbum;
    string idArtist;
    string idLyric;
    string idIMVDB;
    string strTrack;
    string strAlbum;
    string strArtist;
    string strArtistAlternate;
    string intCD;
    string intDuration;
    string strGenre;
    string strMood;
    string strStyle;
    string strTheme;
    string strDescriptionEN;
    string strDescriptionDE;
    string strDescriptionFR;
    string strDescriptionCN;
    string strDescriptionIT;
    string strDescriptionJP;
    string strDescriptionRU;
    string strDescriptionES;
    string strDescriptionPT;
    string strDescriptionSE;
    string strDescriptionNL;
    string strDescriptionHU;
    string strDescriptionNO;
    string strDescriptionIL;
    string strDescriptionPL;
    string strTrackThumb;
    string strTrack3DCase;
    string strTrackLyrics;
    string strMusicVid;
    string strMusicVidDirector;
    string strMusicVidCompany;
    string strMusicVidScreen1;
    string strMusicVidScreen2;
    string strMusicVidScreen3;
    string intMusicVidViews;
    string intMusicVidLikes;
    string intMusicVidDislikes;
    string intMusicVidFavorites;
    string intMusicVidComments;
    string intTrackNumber;
    string intLoved;
    string intScore;
    string intScoreVotes;
    string intTotalListeners;
    string intTotalPlays;
    string strMusicBrainzID;
    string strMusicBrainzAlbumID;
    string strMusicBrainzArtistID;
    string strLocked;
}

struct MusicVideo
{
    string idArtist;
    string idAlbum;
    string idTrack;
    string strTrack;
    string strTrackThumb;
    string strMusicVid;
    string strDescriptionEN;
}

class AudioDBException : Exception
{
    this(string msg, string file = __FILE__, size_t line = __LINE__)
    {
        super(msg, file, line);
    }
}

private string getRequest(string endpoint) {
    auto response = byLineAsync(format("https://theaudiodb.com/api/v1/json/2/%s", endpoint));
    string content = "";
    foreach (line; response)
        content ~= line;
    return content;
}

/** 
 * Params:
 *   s
 * Returns: Artist details from artist name
 * Throws: AudioDBException on failure
 */
Artist searchArtist(string s) {
    try
    {
        auto response = getRequest(format("search.php?s=%s", s.encode));
        if (response.length == 0)
        {
            throw new Exception("no results found");
        }
        JSONValue json = parseJSON(response); 
        if (json["artists"].type != JSONType.null_ && json["artists"].array.length != 0) {
            Artist data = {
                json["artists"][0]["idArtist"].isNull() ? json["artists"][0]["idArtist"].toString : strip(json["artists"][0]["idArtist"].str).length == 0 ? "null" :json["artists"][0]["idArtist"].str,
                json["artists"][0]["strArtist"].isNull() ? json["artists"][0]["strArtist"].toString : strip(json["artists"][0]["strArtist"].str).length == 0 ? "null" :json["artists"][0]["strArtist"].str,
                json["artists"][0]["strArtistStripped"].isNull() ? json["artists"][0]["strArtistStripped"].toString : strip(json["artists"][0]["strArtistStripped"].str).length == 0 ? "null" :json["artists"][0]["strArtistStripped"].str,
                json["artists"][0]["strArtistAlternate"].isNull() ? json["artists"][0]["strArtistAlternate"].toString : strip(json["artists"][0]["strArtistAlternate"].str).length == 0 ? "null" :json["artists"][0]["strArtistAlternate"].str,
                json["artists"][0]["strLabel"].isNull() ? json["artists"][0]["strLabel"].toString : strip(json["artists"][0]["strLabel"].str).length == 0 ? "null" :json["artists"][0]["strLabel"].str,
                json["artists"][0]["idLabel"].isNull() ? json["artists"][0]["idLabel"].toString : strip(json["artists"][0]["idLabel"].str).length == 0 ? "null" :json["artists"][0]["idLabel"].str,
                json["artists"][0]["intFormedYear"].isNull() ? json["artists"][0]["intFormedYear"].toString : strip(json["artists"][0]["intFormedYear"].str).length == 0 ? "null" :json["artists"][0]["intFormedYear"].str,
                json["artists"][0]["intBornYear"].isNull() ? json["artists"][0]["intBornYear"].toString : strip(json["artists"][0]["intBornYear"].str).length == 0 ? "null" :json["artists"][0]["intBornYear"].str,
                json["artists"][0]["intDiedYear"].isNull() ? json["artists"][0]["intDiedYear"].toString : strip(json["artists"][0]["intDiedYear"].str).length == 0 ? "null" :json["artists"][0]["intDiedYear"].str,
                json["artists"][0]["strDisbanded"].isNull() ? json["artists"][0]["strDisbanded"].toString : strip(json["artists"][0]["strDisbanded"].str).length == 0 ? "null" :json["artists"][0]["strDisbanded"].str,
                json["artists"][0]["strStyle"].isNull() ? json["artists"][0]["strStyle"].toString : strip(json["artists"][0]["strStyle"].str).length == 0 ? "null" :json["artists"][0]["strStyle"].str,
                json["artists"][0]["strGenre"].isNull() ? json["artists"][0]["strGenre"].toString : strip(json["artists"][0]["strGenre"].str).length == 0 ? "null" :json["artists"][0]["strGenre"].str,
                json["artists"][0]["strMood"].isNull() ? json["artists"][0]["strMood"].toString : strip(json["artists"][0]["strMood"].str).length == 0 ? "null" :json["artists"][0]["strMood"].str,
                json["artists"][0]["strWebsite"].isNull() ? json["artists"][0]["strWebsite"].toString : strip(json["artists"][0]["strWebsite"].str).length == 0 ? "null" :json["artists"][0]["strWebsite"].str,
                json["artists"][0]["strFacebook"].isNull() ? json["artists"][0]["strFacebook"].toString : strip(json["artists"][0]["strFacebook"].str).length == 0 ? "null" :json["artists"][0]["strFacebook"].str,
                json["artists"][0]["strTwitter"].isNull() ? json["artists"][0]["strTwitter"].toString : strip(json["artists"][0]["strTwitter"].str).length == 0 ? "null" :json["artists"][0]["strTwitter"].str,
                json["artists"][0]["strBiographyEN"].isNull() ? json["artists"][0]["strBiographyEN"].toString : strip(json["artists"][0]["strBiographyEN"].str).length == 0 ? "null" :json["artists"][0]["strBiographyEN"].str,
                json["artists"][0]["strBiographyDE"].isNull() ? json["artists"][0]["strBiographyDE"].toString : strip(json["artists"][0]["strBiographyDE"].str).length == 0 ? "null" :json["artists"][0]["strBiographyDE"].str,
                json["artists"][0]["strBiographyFR"].isNull() ? json["artists"][0]["strBiographyFR"].toString : strip(json["artists"][0]["strBiographyFR"].str).length == 0 ? "null" :json["artists"][0]["strBiographyFR"].str,
                json["artists"][0]["strBiographyCN"].isNull() ? json["artists"][0]["strBiographyCN"].toString : strip(json["artists"][0]["strBiographyCN"].str).length == 0 ? "null" :json["artists"][0]["strBiographyCN"].str,
                json["artists"][0]["strBiographyIT"].isNull() ? json["artists"][0]["strBiographyIT"].toString : strip(json["artists"][0]["strBiographyIT"].str).length == 0 ? "null" :json["artists"][0]["strBiographyIT"].str,
                json["artists"][0]["strBiographyJP"].isNull() ? json["artists"][0]["strBiographyJP"].toString : strip(json["artists"][0]["strBiographyJP"].str).length == 0 ? "null" :json["artists"][0]["strBiographyJP"].str,
                json["artists"][0]["strBiographyRU"].isNull() ? json["artists"][0]["strBiographyRU"].toString : strip(json["artists"][0]["strBiographyRU"].str).length == 0 ? "null" :json["artists"][0]["strBiographyRU"].str,
                json["artists"][0]["strBiographyES"].isNull() ? json["artists"][0]["strBiographyES"].toString : strip(json["artists"][0]["strBiographyES"].str).length == 0 ? "null" :json["artists"][0]["strBiographyES"].str,
                json["artists"][0]["strBiographyPT"].isNull() ? json["artists"][0]["strBiographyPT"].toString : strip(json["artists"][0]["strBiographyPT"].str).length == 0 ? "null" :json["artists"][0]["strBiographyPT"].str,
                json["artists"][0]["strBiographySE"].isNull() ? json["artists"][0]["strBiographySE"].toString : strip(json["artists"][0]["strBiographySE"].str).length == 0 ? "null" :json["artists"][0]["strBiographySE"].str,
                json["artists"][0]["strBiographyNL"].isNull() ? json["artists"][0]["strBiographyNL"].toString : strip(json["artists"][0]["strBiographyNL"].str).length == 0 ? "null" :json["artists"][0]["strBiographyNL"].str,
                json["artists"][0]["strBiographyHU"].isNull() ? json["artists"][0]["strBiographyHU"].toString : strip(json["artists"][0]["strBiographyHU"].str).length == 0 ? "null" :json["artists"][0]["strBiographyHU"].str,
                json["artists"][0]["strBiographyNO"].isNull() ? json["artists"][0]["strBiographyNO"].toString : strip(json["artists"][0]["strBiographyNO"].str).length == 0 ? "null" :json["artists"][0]["strBiographyNO"].str,
                json["artists"][0]["strBiographyIL"].isNull() ? json["artists"][0]["strBiographyIL"].toString : strip(json["artists"][0]["strBiographyIL"].str).length == 0 ? "null" :json["artists"][0]["strBiographyIL"].str,
                json["artists"][0]["strBiographyPL"].isNull() ? json["artists"][0]["strBiographyPL"].toString : strip(json["artists"][0]["strBiographyPL"].str).length == 0 ? "null" :json["artists"][0]["strBiographyPL"].str,
                json["artists"][0]["strGender"].isNull() ? json["artists"][0]["strGender"].toString : strip(json["artists"][0]["strGender"].str).length == 0 ? "null" :json["artists"][0]["strGender"].str,
                json["artists"][0]["intMembers"].isNull() ? json["artists"][0]["intMembers"].toString : strip(json["artists"][0]["intMembers"].str).length == 0 ? "null" :json["artists"][0]["intMembers"].str,
                json["artists"][0]["strCountry"].isNull() ? json["artists"][0]["strCountry"].toString : strip(json["artists"][0]["strCountry"].str).length == 0 ? "null" :json["artists"][0]["strCountry"].str,
                json["artists"][0]["strCountryCode"].isNull() ? json["artists"][0]["strCountryCode"].toString : strip(json["artists"][0]["strCountryCode"].str).length == 0 ? "null" :json["artists"][0]["strCountryCode"].str,
                json["artists"][0]["strArtistThumb"].isNull() ? json["artists"][0]["strArtistThumb"].toString : strip(json["artists"][0]["strArtistThumb"].str).length == 0 ? "null" :json["artists"][0]["strArtistThumb"].str,
                json["artists"][0]["strArtistLogo"].isNull() ? json["artists"][0]["strArtistLogo"].toString : strip(json["artists"][0]["strArtistLogo"].str).length == 0 ? "null" :json["artists"][0]["strArtistLogo"].str,
                json["artists"][0]["strArtistCutout"].isNull() ? json["artists"][0]["strArtistCutout"].toString : strip(json["artists"][0]["strArtistCutout"].str).length == 0 ? "null" :json["artists"][0]["strArtistCutout"].str,
                json["artists"][0]["strArtistClearart"].isNull() ? json["artists"][0]["strArtistClearart"].toString : strip(json["artists"][0]["strArtistClearart"].str).length == 0 ? "null" :json["artists"][0]["strArtistClearart"].str,
                json["artists"][0]["strArtistWideThumb"].isNull() ? json["artists"][0]["strArtistWideThumb"].toString : strip(json["artists"][0]["strArtistWideThumb"].str).length == 0 ? "null" :json["artists"][0]["strArtistWideThumb"].str,
                json["artists"][0]["strArtistFanart"].isNull() ? json["artists"][0]["strArtistFanart"].toString : strip(json["artists"][0]["strArtistFanart"].str).length == 0 ? "null" :json["artists"][0]["strArtistFanart"].str,
                json["artists"][0]["strArtistFanart2"].isNull() ? json["artists"][0]["strArtistFanart2"].toString : strip(json["artists"][0]["strArtistFanart2"].str).length == 0 ? "null" :json["artists"][0]["strArtistFanart2"].str,
                json["artists"][0]["strArtistFanart3"].isNull() ? json["artists"][0]["strArtistFanart3"].toString : strip(json["artists"][0]["strArtistFanart3"].str).length == 0 ? "null" :json["artists"][0]["strArtistFanart3"].str,
                json["artists"][0]["strArtistFanart4"].isNull() ? json["artists"][0]["strArtistFanart4"].toString : strip(json["artists"][0]["strArtistFanart4"].str).length == 0 ? "null" :json["artists"][0]["strArtistFanart4"].str,
                json["artists"][0]["strArtistBanner"].isNull() ? json["artists"][0]["strArtistBanner"].toString : strip(json["artists"][0]["strArtistBanner"].str).length == 0 ? "null" :json["artists"][0]["strArtistBanner"].str,
                json["artists"][0]["strMusicBrainzID"].isNull() ? json["artists"][0]["strMusicBrainzID"].toString : strip(json["artists"][0]["strMusicBrainzID"].str).length == 0 ? "null" :json["artists"][0]["strMusicBrainzID"].str,
                json["artists"][0]["strISNIcode"].isNull() ? json["artists"][0]["strISNIcode"].toString : strip(json["artists"][0]["strISNIcode"].str).length == 0 ? "null" :json["artists"][0]["strISNIcode"].str,
                json["artists"][0]["strLastFMChart"].isNull() ? json["artists"][0]["strLastFMChart"].toString : strip(json["artists"][0]["strLastFMChart"].str).length == 0 ? "null" :json["artists"][0]["strLastFMChart"].str,
                json["artists"][0]["intCharted"].isNull() ? json["artists"][0]["intCharted"].toString : strip(json["artists"][0]["intCharted"].str).length == 0 ? "null" :json["artists"][0]["intCharted"].str,
                json["artists"][0]["strLocked"].isNull() ? json["artists"][0]["strLocked"].toString : strip(json["artists"][0]["strLocked"].str).length == 0 ? "null" :json["artists"][0]["strLocked"].str,
            };
            return data;
        }
        throw new Exception("no results found");
    }
    catch(CurlException ex)
    {
        throw new AudioDBException(ex.msg);
    }
    catch(JSONException ex)
    {
        throw new AudioDBException(format("Something went wrong while parsing json: %s", ex.msg));
    }
    catch(Exception ex)
    {
        throw new AudioDBException(ex.msg);
    }
}

/** 
 * Params:
 *   s
 * Returns: Discography for an Artist with Album names and year only
 * Throws: AudioDBException on failure
 */
Discography[] discography(string s) {
    try
    {
        auto response = getRequest(format("discography.php?s=%s", s.encode));
        if (response.length == 0)
        {
            throw new Exception("no results found");
        }
        JSONValue json = parseJSON(response); 
        if (json["album"].type != JSONType.null_ && json["album"].array.length != 0) {
            Discography[] array = [];
            foreach(ref i; json["album"].array)
            {
                Discography data = {
                    i["strAlbum"].isNull() ? i["strAlbum"].toString : strip(i["strAlbum"].str).length == 0 ? "null" :i["strAlbum"].str,
                    i["intYearReleased"].isNull() ? i["intYearReleased"].toString : strip(i["intYearReleased"].str).length == 0 ? "null" :i["intYearReleased"].str,
                };
                array ~= data;
            }
            return array;
        }
        throw new Exception("no results found");
    }
    catch(CurlException ex)
    {
        throw new AudioDBException(ex.msg);
    }
    catch(JSONException ex)
    {
        throw new AudioDBException(format("Something went wrong while parsing json: %s", ex.msg));
    }
    catch(Exception ex)
    {
        throw new AudioDBException(ex.msg);
    }
}

/** 
 * Params:
 *   l
 * Returns: individual Artist details using known Artist ID
 * Throws: AudioDBException on failure
 */
Artist searchArtistById(long l) {
    try
    {
        auto response = getRequest(format("artist.php?i=%d", l));
        if (response.length == 0)
        {
            throw new Exception("no results found");
        }
        JSONValue json = parseJSON(response); 
        if (json["artists"].type != JSONType.null_ && json["artists"].array.length != 0) {
            Artist data = {
                json["artists"][0]["idArtist"].isNull() ? json["artists"][0]["idArtist"].toString : strip(json["artists"][0]["idArtist"].str).length == 0 ? "null" :json["artists"][0]["idArtist"].str,
                json["artists"][0]["strArtist"].isNull() ? json["artists"][0]["strArtist"].toString : strip(json["artists"][0]["strArtist"].str).length == 0 ? "null" :json["artists"][0]["strArtist"].str,
                json["artists"][0]["strArtistStripped"].isNull() ? json["artists"][0]["strArtistStripped"].toString : strip(json["artists"][0]["strArtistStripped"].str).length == 0 ? "null" :json["artists"][0]["strArtistStripped"].str,
                json["artists"][0]["strArtistAlternate"].isNull() ? json["artists"][0]["strArtistAlternate"].toString : strip(json["artists"][0]["strArtistAlternate"].str).length == 0 ? "null" :json["artists"][0]["strArtistAlternate"].str,
                json["artists"][0]["strLabel"].isNull() ? json["artists"][0]["strLabel"].toString : strip(json["artists"][0]["strLabel"].str).length == 0 ? "null" :json["artists"][0]["strLabel"].str,
                json["artists"][0]["idLabel"].isNull() ? json["artists"][0]["idLabel"].toString : strip(json["artists"][0]["idLabel"].str).length == 0 ? "null" :json["artists"][0]["idLabel"].str,
                json["artists"][0]["intFormedYear"].isNull() ? json["artists"][0]["intFormedYear"].toString : strip(json["artists"][0]["intFormedYear"].str).length == 0 ? "null" :json["artists"][0]["intFormedYear"].str,
                json["artists"][0]["intBornYear"].isNull() ? json["artists"][0]["intBornYear"].toString : strip(json["artists"][0]["intBornYear"].str).length == 0 ? "null" :json["artists"][0]["intBornYear"].str,
                json["artists"][0]["intDiedYear"].isNull() ? json["artists"][0]["intDiedYear"].toString : strip(json["artists"][0]["intDiedYear"].str).length == 0 ? "null" :json["artists"][0]["intDiedYear"].str,
                json["artists"][0]["strDisbanded"].isNull() ? json["artists"][0]["strDisbanded"].toString : strip(json["artists"][0]["strDisbanded"].str).length == 0 ? "null" :json["artists"][0]["strDisbanded"].str,
                json["artists"][0]["strStyle"].isNull() ? json["artists"][0]["strStyle"].toString : strip(json["artists"][0]["strStyle"].str).length == 0 ? "null" :json["artists"][0]["strStyle"].str,
                json["artists"][0]["strGenre"].isNull() ? json["artists"][0]["strGenre"].toString : strip(json["artists"][0]["strGenre"].str).length == 0 ? "null" :json["artists"][0]["strGenre"].str,
                json["artists"][0]["strMood"].isNull() ? json["artists"][0]["strMood"].toString : strip(json["artists"][0]["strMood"].str).length == 0 ? "null" :json["artists"][0]["strMood"].str,
                json["artists"][0]["strWebsite"].isNull() ? json["artists"][0]["strWebsite"].toString : strip(json["artists"][0]["strWebsite"].str).length == 0 ? "null" :json["artists"][0]["strWebsite"].str,
                json["artists"][0]["strFacebook"].isNull() ? json["artists"][0]["strFacebook"].toString : strip(json["artists"][0]["strFacebook"].str).length == 0 ? "null" :json["artists"][0]["strFacebook"].str,
                json["artists"][0]["strTwitter"].isNull() ? json["artists"][0]["strTwitter"].toString : strip(json["artists"][0]["strTwitter"].str).length == 0 ? "null" :json["artists"][0]["strTwitter"].str,
                json["artists"][0]["strBiographyEN"].isNull() ? json["artists"][0]["strBiographyEN"].toString : strip(json["artists"][0]["strBiographyEN"].str).length == 0 ? "null" :json["artists"][0]["strBiographyEN"].str,
                json["artists"][0]["strBiographyDE"].isNull() ? json["artists"][0]["strBiographyDE"].toString : strip(json["artists"][0]["strBiographyDE"].str).length == 0 ? "null" :json["artists"][0]["strBiographyDE"].str,
                json["artists"][0]["strBiographyFR"].isNull() ? json["artists"][0]["strBiographyFR"].toString : strip(json["artists"][0]["strBiographyFR"].str).length == 0 ? "null" :json["artists"][0]["strBiographyFR"].str,
                json["artists"][0]["strBiographyCN"].isNull() ? json["artists"][0]["strBiographyCN"].toString : strip(json["artists"][0]["strBiographyCN"].str).length == 0 ? "null" :json["artists"][0]["strBiographyCN"].str,
                json["artists"][0]["strBiographyIT"].isNull() ? json["artists"][0]["strBiographyIT"].toString : strip(json["artists"][0]["strBiographyIT"].str).length == 0 ? "null" :json["artists"][0]["strBiographyIT"].str,
                json["artists"][0]["strBiographyJP"].isNull() ? json["artists"][0]["strBiographyJP"].toString : strip(json["artists"][0]["strBiographyJP"].str).length == 0 ? "null" :json["artists"][0]["strBiographyJP"].str,
                json["artists"][0]["strBiographyRU"].isNull() ? json["artists"][0]["strBiographyRU"].toString : strip(json["artists"][0]["strBiographyRU"].str).length == 0 ? "null" :json["artists"][0]["strBiographyRU"].str,
                json["artists"][0]["strBiographyES"].isNull() ? json["artists"][0]["strBiographyES"].toString : strip(json["artists"][0]["strBiographyES"].str).length == 0 ? "null" :json["artists"][0]["strBiographyES"].str,
                json["artists"][0]["strBiographyPT"].isNull() ? json["artists"][0]["strBiographyPT"].toString : strip(json["artists"][0]["strBiographyPT"].str).length == 0 ? "null" :json["artists"][0]["strBiographyPT"].str,
                json["artists"][0]["strBiographySE"].isNull() ? json["artists"][0]["strBiographySE"].toString : strip(json["artists"][0]["strBiographySE"].str).length == 0 ? "null" :json["artists"][0]["strBiographySE"].str,
                json["artists"][0]["strBiographyNL"].isNull() ? json["artists"][0]["strBiographyNL"].toString : strip(json["artists"][0]["strBiographyNL"].str).length == 0 ? "null" :json["artists"][0]["strBiographyNL"].str,
                json["artists"][0]["strBiographyHU"].isNull() ? json["artists"][0]["strBiographyHU"].toString : strip(json["artists"][0]["strBiographyHU"].str).length == 0 ? "null" :json["artists"][0]["strBiographyHU"].str,
                json["artists"][0]["strBiographyNO"].isNull() ? json["artists"][0]["strBiographyNO"].toString : strip(json["artists"][0]["strBiographyNO"].str).length == 0 ? "null" :json["artists"][0]["strBiographyNO"].str,
                json["artists"][0]["strBiographyIL"].isNull() ? json["artists"][0]["strBiographyIL"].toString : strip(json["artists"][0]["strBiographyIL"].str).length == 0 ? "null" :json["artists"][0]["strBiographyIL"].str,
                json["artists"][0]["strBiographyPL"].isNull() ? json["artists"][0]["strBiographyPL"].toString : strip(json["artists"][0]["strBiographyPL"].str).length == 0 ? "null" :json["artists"][0]["strBiographyPL"].str,
                json["artists"][0]["strGender"].isNull() ? json["artists"][0]["strGender"].toString : strip(json["artists"][0]["strGender"].str).length == 0 ? "null" :json["artists"][0]["strGender"].str,
                json["artists"][0]["intMembers"].isNull() ? json["artists"][0]["intMembers"].toString : strip(json["artists"][0]["intMembers"].str).length == 0 ? "null" :json["artists"][0]["intMembers"].str,
                json["artists"][0]["strCountry"].isNull() ? json["artists"][0]["strCountry"].toString : strip(json["artists"][0]["strCountry"].str).length == 0 ? "null" :json["artists"][0]["strCountry"].str,
                json["artists"][0]["strCountryCode"].isNull() ? json["artists"][0]["strCountryCode"].toString : strip(json["artists"][0]["strCountryCode"].str).length == 0 ? "null" :json["artists"][0]["strCountryCode"].str,
                json["artists"][0]["strArtistThumb"].isNull() ? json["artists"][0]["strArtistThumb"].toString : strip(json["artists"][0]["strArtistThumb"].str).length == 0 ? "null" :json["artists"][0]["strArtistThumb"].str,
                json["artists"][0]["strArtistLogo"].isNull() ? json["artists"][0]["strArtistLogo"].toString : strip(json["artists"][0]["strArtistLogo"].str).length == 0 ? "null" :json["artists"][0]["strArtistLogo"].str,
                json["artists"][0]["strArtistCutout"].isNull() ? json["artists"][0]["strArtistCutout"].toString : strip(json["artists"][0]["strArtistCutout"].str).length == 0 ? "null" :json["artists"][0]["strArtistCutout"].str,
                json["artists"][0]["strArtistClearart"].isNull() ? json["artists"][0]["strArtistClearart"].toString : strip(json["artists"][0]["strArtistClearart"].str).length == 0 ? "null" :json["artists"][0]["strArtistClearart"].str,
                json["artists"][0]["strArtistWideThumb"].isNull() ? json["artists"][0]["strArtistWideThumb"].toString : strip(json["artists"][0]["strArtistWideThumb"].str).length == 0 ? "null" :json["artists"][0]["strArtistWideThumb"].str,
                json["artists"][0]["strArtistFanart"].isNull() ? json["artists"][0]["strArtistFanart"].toString : strip(json["artists"][0]["strArtistFanart"].str).length == 0 ? "null" :json["artists"][0]["strArtistFanart"].str,
                json["artists"][0]["strArtistFanart2"].isNull() ? json["artists"][0]["strArtistFanart2"].toString : strip(json["artists"][0]["strArtistFanart2"].str).length == 0 ? "null" :json["artists"][0]["strArtistFanart2"].str,
                json["artists"][0]["strArtistFanart3"].isNull() ? json["artists"][0]["strArtistFanart3"].toString : strip(json["artists"][0]["strArtistFanart3"].str).length == 0 ? "null" :json["artists"][0]["strArtistFanart3"].str,
                json["artists"][0]["strArtistFanart4"].isNull() ? json["artists"][0]["strArtistFanart4"].toString : strip(json["artists"][0]["strArtistFanart4"].str).length == 0 ? "null" :json["artists"][0]["strArtistFanart4"].str,
                json["artists"][0]["strArtistBanner"].isNull() ? json["artists"][0]["strArtistBanner"].toString : strip(json["artists"][0]["strArtistBanner"].str).length == 0 ? "null" :json["artists"][0]["strArtistBanner"].str,
                json["artists"][0]["strMusicBrainzID"].isNull() ? json["artists"][0]["strMusicBrainzID"].toString : strip(json["artists"][0]["strMusicBrainzID"].str).length == 0 ? "null" :json["artists"][0]["strMusicBrainzID"].str,
                json["artists"][0]["strISNIcode"].isNull() ? json["artists"][0]["strISNIcode"].toString : strip(json["artists"][0]["strISNIcode"].str).length == 0 ? "null" :json["artists"][0]["strISNIcode"].str,
                json["artists"][0]["strLastFMChart"].isNull() ? json["artists"][0]["strLastFMChart"].toString : strip(json["artists"][0]["strLastFMChart"].str).length == 0 ? "null" :json["artists"][0]["strLastFMChart"].str,
                json["artists"][0]["intCharted"].isNull() ? json["artists"][0]["intCharted"].toString : strip(json["artists"][0]["intCharted"].str).length == 0 ? "null" :json["artists"][0]["intCharted"].str,
                json["artists"][0]["strLocked"].isNull() ? json["artists"][0]["strLocked"].toString : strip(json["artists"][0]["strLocked"].str).length == 0 ? "null" :json["artists"][0]["strLocked"].str,
            };
            return data;
        }
        throw new Exception("no results found");
    }
    catch(CurlException ex)
    {
        throw new AudioDBException(ex.msg);
    }
    catch(JSONException ex)
    {
        throw new AudioDBException(format("Something went wrong while parsing json: %s", ex.msg));
    }
    catch(Exception ex)
    {
        throw new AudioDBException(ex.msg);
    }
}

/** 
 * Params:
 *   l
 * Returns: individual Album info using known Album ID
 * Throws: AudioDBException on failure
 */
Album searchAlbumById(long l) {
    try
    {
        auto response = getRequest(format("album.php?m=%d", l));
        if (response.length == 0)
        {
            throw new Exception("no results found");
        }
        JSONValue json = parseJSON(response); 
        if (json["album"].type != JSONType.null_ && json["album"].array.length != 0) {
            Album data = {
                json["album"][0]["idAlbum"].isNull() ? json["album"][0]["idAlbum"].toString : strip(json["album"][0]["idAlbum"].str).length == 0 ? "null" :json["album"][0]["idAlbum"].str,
                json["album"][0]["idArtist"].isNull() ? json["album"][0]["idArtist"].toString : strip(json["album"][0]["idArtist"].str).length == 0 ? "null" :json["album"][0]["idArtist"].str,
                json["album"][0]["idLabel"].isNull() ? json["album"][0]["idLabel"].toString : strip(json["album"][0]["idLabel"].str).length == 0 ? "null" :json["album"][0]["idLabel"].str,
                json["album"][0]["strAlbum"].isNull() ? json["album"][0]["strAlbum"].toString : strip(json["album"][0]["strAlbum"].str).length == 0 ? "null" :json["album"][0]["strAlbum"].str,
                json["album"][0]["strAlbumStripped"].isNull() ? json["album"][0]["strAlbumStripped"].toString : strip(json["album"][0]["strAlbumStripped"].str).length == 0 ? "null" :json["album"][0]["strAlbumStripped"].str,
                json["album"][0]["strArtist"].isNull() ? json["album"][0]["strArtist"].toString : strip(json["album"][0]["strArtist"].str).length == 0 ? "null" :json["album"][0]["strArtist"].str,
                json["album"][0]["strArtistStripped"].isNull() ? json["album"][0]["strArtistStripped"].toString : strip(json["album"][0]["strArtistStripped"].str).length == 0 ? "null" :json["album"][0]["strArtistStripped"].str,
                json["album"][0]["intYearReleased"].isNull() ? json["album"][0]["intYearReleased"].toString : strip(json["album"][0]["intYearReleased"].str).length == 0 ? "null" :json["album"][0]["intYearReleased"].str,
                json["album"][0]["strStyle"].isNull() ? json["album"][0]["strStyle"].toString : strip(json["album"][0]["strStyle"].str).length == 0 ? "null" :json["album"][0]["strStyle"].str,
                json["album"][0]["strGenre"].isNull() ? json["album"][0]["strGenre"].toString : strip(json["album"][0]["strGenre"].str).length == 0 ? "null" :json["album"][0]["strGenre"].str,
                json["album"][0]["strLabel"].isNull() ? json["album"][0]["strLabel"].toString : strip(json["album"][0]["strLabel"].str).length == 0 ? "null" :json["album"][0]["strLabel"].str,
                json["album"][0]["strReleaseFormat"].isNull() ? json["album"][0]["strReleaseFormat"].toString : strip(json["album"][0]["strReleaseFormat"].str).length == 0 ? "null" :json["album"][0]["strReleaseFormat"].str,
                json["album"][0]["intSales"].isNull() ? json["album"][0]["intSales"].toString : strip(json["album"][0]["intSales"].str).length == 0 ? "null" :json["album"][0]["intSales"].str,
                json["album"][0]["strAlbumThumb"].isNull() ? json["album"][0]["strAlbumThumb"].toString : strip(json["album"][0]["strAlbumThumb"].str).length == 0 ? "null" :json["album"][0]["strAlbumThumb"].str,
                json["album"][0]["strAlbumThumbHQ"].isNull() ? json["album"][0]["strAlbumThumbHQ"].toString : strip(json["album"][0]["strAlbumThumbHQ"].str).length == 0 ? "null" :json["album"][0]["strAlbumThumbHQ"].str,
                json["album"][0]["strAlbumThumbBack"].isNull() ? json["album"][0]["strAlbumThumbBack"].toString : strip(json["album"][0]["strAlbumThumbBack"].str).length == 0 ? "null" :json["album"][0]["strAlbumThumbBack"].str,
                json["album"][0]["strAlbumCDart"].isNull() ? json["album"][0]["strAlbumCDart"].toString : strip(json["album"][0]["strAlbumCDart"].str).length == 0 ? "null" :json["album"][0]["strAlbumCDart"].str,
                json["album"][0]["strAlbumSpine"].isNull() ? json["album"][0]["strAlbumSpine"].toString : strip(json["album"][0]["strAlbumSpine"].str).length == 0 ? "null" :json["album"][0]["strAlbumSpine"].str,
                json["album"][0]["strAlbum3DCase"].isNull() ? json["album"][0]["strAlbum3DCase"].toString : strip(json["album"][0]["strAlbum3DCase"].str).length == 0 ? "null" :json["album"][0]["strAlbum3DCase"].str,
                json["album"][0]["strAlbum3DFlat"].isNull() ? json["album"][0]["strAlbum3DFlat"].toString : strip(json["album"][0]["strAlbum3DFlat"].str).length == 0 ? "null" :json["album"][0]["strAlbum3DFlat"].str,
                json["album"][0]["strAlbum3DFace"].isNull() ? json["album"][0]["strAlbum3DFace"].toString : strip(json["album"][0]["strAlbum3DFace"].str).length == 0 ? "null" :json["album"][0]["strAlbum3DFace"].str,
                json["album"][0]["strAlbum3DThumb"].isNull() ? json["album"][0]["strAlbum3DThumb"].toString : strip(json["album"][0]["strAlbum3DThumb"].str).length == 0 ? "null" :json["album"][0]["strAlbum3DThumb"].str,
                json["album"][0]["strDescriptionDE"].isNull() ? json["album"][0]["strDescriptionDE"].toString : strip(json["album"][0]["strDescriptionDE"].str).length == 0 ? "null" :json["album"][0]["strDescriptionDE"].str,
                json["album"][0]["strDescriptionFR"].isNull() ? json["album"][0]["strDescriptionFR"].toString : strip(json["album"][0]["strDescriptionFR"].str).length == 0 ? "null" :json["album"][0]["strDescriptionFR"].str,
                json["album"][0]["strDescriptionCN"].isNull() ? json["album"][0]["strDescriptionCN"].toString : strip(json["album"][0]["strDescriptionCN"].str).length == 0 ? "null" :json["album"][0]["strDescriptionCN"].str,
                json["album"][0]["strDescriptionIT"].isNull() ? json["album"][0]["strDescriptionIT"].toString : strip(json["album"][0]["strDescriptionIT"].str).length == 0 ? "null" :json["album"][0]["strDescriptionIT"].str,
                json["album"][0]["strDescriptionJP"].isNull() ? json["album"][0]["strDescriptionJP"].toString : strip(json["album"][0]["strDescriptionJP"].str).length == 0 ? "null" :json["album"][0]["strDescriptionJP"].str,
                json["album"][0]["strDescriptionRU"].isNull() ? json["album"][0]["strDescriptionRU"].toString : strip(json["album"][0]["strDescriptionRU"].str).length == 0 ? "null" :json["album"][0]["strDescriptionRU"].str,
                json["album"][0]["strDescriptionES"].isNull() ? json["album"][0]["strDescriptionES"].toString : strip(json["album"][0]["strDescriptionES"].str).length == 0 ? "null" :json["album"][0]["strDescriptionES"].str,
                json["album"][0]["strDescriptionPT"].isNull() ? json["album"][0]["strDescriptionPT"].toString : strip(json["album"][0]["strDescriptionPT"].str).length == 0 ? "null" :json["album"][0]["strDescriptionPT"].str,
                json["album"][0]["strDescriptionSE"].isNull() ? json["album"][0]["strDescriptionSE"].toString : strip(json["album"][0]["strDescriptionSE"].str).length == 0 ? "null" :json["album"][0]["strDescriptionSE"].str,
                json["album"][0]["strDescriptionNL"].isNull() ? json["album"][0]["strDescriptionNL"].toString : strip(json["album"][0]["strDescriptionNL"].str).length == 0 ? "null" :json["album"][0]["strDescriptionNL"].str,
                json["album"][0]["strDescriptionHU"].isNull() ? json["album"][0]["strDescriptionHU"].toString : strip(json["album"][0]["strDescriptionHU"].str).length == 0 ? "null" :json["album"][0]["strDescriptionHU"].str,
                json["album"][0]["strDescriptionNO"].isNull() ? json["album"][0]["strDescriptionNO"].toString : strip(json["album"][0]["strDescriptionNO"].str).length == 0 ? "null" :json["album"][0]["strDescriptionNO"].str,
                json["album"][0]["strDescriptionIL"].isNull() ? json["album"][0]["strDescriptionIL"].toString : strip(json["album"][0]["strDescriptionIL"].str).length == 0 ? "null" :json["album"][0]["strDescriptionIL"].str,
                json["album"][0]["strDescriptionPL"].isNull() ? json["album"][0]["strDescriptionPL"].toString : strip(json["album"][0]["strDescriptionPL"].str).length == 0 ? "null" :json["album"][0]["strDescriptionPL"].str,
                json["album"][0]["intLoved"].isNull() ? json["album"][0]["intLoved"].toString : strip(json["album"][0]["intLoved"].str).length == 0 ? "null" :json["album"][0]["intLoved"].str,
                json["album"][0]["intScore"].isNull() ? json["album"][0]["intScore"].toString : strip(json["album"][0]["intScore"].str).length == 0 ? "null" :json["album"][0]["intScore"].str,
                json["album"][0]["intScoreVotes"].isNull() ? json["album"][0]["intScoreVotes"].toString : strip(json["album"][0]["intScoreVotes"].str).length == 0 ? "null" :json["album"][0]["intScoreVotes"].str,
                json["album"][0]["strReview"].isNull() ? json["album"][0]["strReview"].toString : strip(json["album"][0]["strReview"].str).length == 0 ? "null" :json["album"][0]["strReview"].str,
                json["album"][0]["strMood"].isNull() ? json["album"][0]["strMood"].toString : strip(json["album"][0]["strMood"].str).length == 0 ? "null" :json["album"][0]["strMood"].str,
                json["album"][0]["strTheme"].isNull() ? json["album"][0]["strTheme"].toString : strip(json["album"][0]["strTheme"].str).length == 0 ? "null" :json["album"][0]["strTheme"].str,
                json["album"][0]["strSpeed"].isNull() ? json["album"][0]["strSpeed"].toString : strip(json["album"][0]["strSpeed"].str).length == 0 ? "null" :json["album"][0]["strSpeed"].str,
                json["album"][0]["strLocation"].isNull() ? json["album"][0]["strLocation"].toString : strip(json["album"][0]["strLocation"].str).length == 0 ? "null" :json["album"][0]["strLocation"].str,
                json["album"][0]["strMusicBrainzID"].isNull() ? json["album"][0]["strMusicBrainzID"].toString : strip(json["album"][0]["strMusicBrainzID"].str).length == 0 ? "null" :json["album"][0]["strMusicBrainzID"].str,
                json["album"][0]["strMusicBrainzArtistID"].isNull() ? json["album"][0]["strMusicBrainzArtistID"].toString : strip(json["album"][0]["strMusicBrainzArtistID"].str).length == 0 ? "null" :json["album"][0]["strMusicBrainzArtistID"].str,
                json["album"][0]["strAllMusicID"].isNull() ? json["album"][0]["strAllMusicID"].toString : strip(json["album"][0]["strAllMusicID"].str).length == 0 ? "null" :json["album"][0]["strAllMusicID"].str,
                json["album"][0]["strBBCReviewID"].isNull() ? json["album"][0]["strBBCReviewID"].toString : strip(json["album"][0]["strBBCReviewID"].str).length == 0 ? "null" :json["album"][0]["strBBCReviewID"].str,
                json["album"][0]["strRateYourMusicID"].isNull() ? json["album"][0]["strRateYourMusicID"].toString : strip(json["album"][0]["strRateYourMusicID"].str).length == 0 ? "null" :json["album"][0]["strRateYourMusicID"].str,
                json["album"][0]["strDiscogsID"].isNull() ? json["album"][0]["strDiscogsID"].toString : strip(json["album"][0]["strDiscogsID"].str).length == 0 ? "null" :json["album"][0]["strDiscogsID"].str,
                json["album"][0]["strWikidataID"].isNull() ? json["album"][0]["strWikidataID"].toString : strip(json["album"][0]["strWikidataID"].str).length == 0 ? "null" :json["album"][0]["strWikidataID"].str,
                json["album"][0]["strWikipediaID"].isNull() ? json["album"][0]["strWikipediaID"].toString : strip(json["album"][0]["strWikipediaID"].str).length == 0 ? "null" :json["album"][0]["strWikipediaID"].str,
                json["album"][0]["strGeniusID"].isNull() ? json["album"][0]["strGeniusID"].toString : strip(json["album"][0]["strGeniusID"].str).length == 0 ? "null" :json["album"][0]["strGeniusID"].str,
                json["album"][0]["strLyricWikiID"].isNull() ? json["album"][0]["strLyricWikiID"].toString : strip(json["album"][0]["strLyricWikiID"].str).length == 0 ? "null" :json["album"][0]["strLyricWikiID"].str,
                json["album"][0]["strMusicMozID"].isNull() ? json["album"][0]["strMusicMozID"].toString : strip(json["album"][0]["strMusicMozID"].str).length == 0 ? "null" :json["album"][0]["strMusicMozID"].str,
                json["album"][0]["strItunesID"].isNull() ? json["album"][0]["strItunesID"].toString : strip(json["album"][0]["strItunesID"].str).length == 0 ? "null" :json["album"][0]["strItunesID"].str,
                json["album"][0]["strAmazonID"].isNull() ? json["album"][0]["strAmazonID"].toString : strip(json["album"][0]["strAmazonID"].str).length == 0 ? "null" :json["album"][0]["strAmazonID"].str,
                json["album"][0]["strLocked"].isNull() ? json["album"][0]["strLocked"].toString : strip(json["album"][0]["strLocked"].str).length == 0 ? "null" :json["album"][0]["strLocked"].str,
            };
            return data;
        }
        throw new Exception("no results found");
    }
    catch(CurlException ex)
    {
        throw new AudioDBException(ex.msg);
    }
    catch(JSONException ex)
    {
        throw new AudioDBException(format("Something went wrong while parsing json: %s", ex.msg));
    }
    catch(Exception ex)
    {
        throw new AudioDBException(ex.msg);
    }
}

/** 
 * Params:
 *   l
 * Returns: All Albums for an Artist using known Artist ID
 * Throws: AudioDBException on failure
 */
Album[] searchAlbumsByArtistId(long l) {
    try
    {
        auto response = getRequest(format("album.php?i=%d", l));
        if (response.length == 0)
        {
            throw new Exception("no results found");
        }
        JSONValue json = parseJSON(response); 
        if (json["album"].type != JSONType.null_ && json["album"].array.length != 0) {
            Album[] array = [];
            foreach(ref i; json["album"].array)
            {
                Album data = {
                    i["idAlbum"].isNull() ? i["idAlbum"].toString : strip(i["idAlbum"].str).length == 0 ? "null" :i["idAlbum"].str,
                    i["idArtist"].isNull() ? i["idArtist"].toString : strip(i["idArtist"].str).length == 0 ? "null" :i["idArtist"].str,
                    i["idLabel"].isNull() ? i["idLabel"].toString : strip(i["idLabel"].str).length == 0 ? "null" :i["idLabel"].str,
                    i["strAlbum"].isNull() ? i["strAlbum"].toString : strip(i["strAlbum"].str).length == 0 ? "null" :i["strAlbum"].str,
                    i["strAlbumStripped"].isNull() ? i["strAlbumStripped"].toString : strip(i["strAlbumStripped"].str).length == 0 ? "null" :i["strAlbumStripped"].str,
                    i["strArtist"].isNull() ? i["strArtist"].toString : strip(i["strArtist"].str).length == 0 ? "null" :i["strArtist"].str,
                    i["strArtistStripped"].isNull() ? i["strArtistStripped"].toString : strip(i["strArtistStripped"].str).length == 0 ? "null" :i["strArtistStripped"].str,
                    i["intYearReleased"].isNull() ? i["intYearReleased"].toString : strip(i["intYearReleased"].str).length == 0 ? "null" :i["intYearReleased"].str,
                    i["strStyle"].isNull() ? i["strStyle"].toString : strip(i["strStyle"].str).length == 0 ? "null" :i["strStyle"].str,
                    i["strGenre"].isNull() ? i["strGenre"].toString : strip(i["strGenre"].str).length == 0 ? "null" :i["strGenre"].str,
                    i["strLabel"].isNull() ? i["strLabel"].toString : strip(i["strLabel"].str).length == 0 ? "null" :i["strLabel"].str,
                    i["strReleaseFormat"].isNull() ? i["strReleaseFormat"].toString : strip(i["strReleaseFormat"].str).length == 0 ? "null" :i["strReleaseFormat"].str,
                    i["intSales"].isNull() ? i["intSales"].toString : strip(i["intSales"].str).length == 0 ? "null" :i["intSales"].str,
                    i["strAlbumThumb"].isNull() ? i["strAlbumThumb"].toString : strip(i["strAlbumThumb"].str).length == 0 ? "null" :i["strAlbumThumb"].str,
                    i["strAlbumThumbHQ"].isNull() ? i["strAlbumThumbHQ"].toString : strip(i["strAlbumThumbHQ"].str).length == 0 ? "null" :i["strAlbumThumbHQ"].str,
                    i["strAlbumThumbBack"].isNull() ? i["strAlbumThumbBack"].toString : strip(i["strAlbumThumbBack"].str).length == 0 ? "null" :i["strAlbumThumbBack"].str,
                    i["strAlbumCDart"].isNull() ? i["strAlbumCDart"].toString : strip(i["strAlbumCDart"].str).length == 0 ? "null" :i["strAlbumCDart"].str,
                    i["strAlbumSpine"].isNull() ? i["strAlbumSpine"].toString : strip(i["strAlbumSpine"].str).length == 0 ? "null" :i["strAlbumSpine"].str,
                    i["strAlbum3DCase"].isNull() ? i["strAlbum3DCase"].toString : strip(i["strAlbum3DCase"].str).length == 0 ? "null" :i["strAlbum3DCase"].str,
                    i["strAlbum3DFlat"].isNull() ? i["strAlbum3DFlat"].toString : strip(i["strAlbum3DFlat"].str).length == 0 ? "null" :i["strAlbum3DFlat"].str,
                    i["strAlbum3DFace"].isNull() ? i["strAlbum3DFace"].toString : strip(i["strAlbum3DFace"].str).length == 0 ? "null" :i["strAlbum3DFace"].str,
                    i["strAlbum3DThumb"].isNull() ? i["strAlbum3DThumb"].toString : strip(i["strAlbum3DThumb"].str).length == 0 ? "null" :i["strAlbum3DThumb"].str,
                    i["strDescriptionDE"].isNull() ? i["strDescriptionDE"].toString : strip(i["strDescriptionDE"].str).length == 0 ? "null" :i["strDescriptionDE"].str,
                    i["strDescriptionFR"].isNull() ? i["strDescriptionFR"].toString : strip(i["strDescriptionFR"].str).length == 0 ? "null" :i["strDescriptionFR"].str,
                    i["strDescriptionCN"].isNull() ? i["strDescriptionCN"].toString : strip(i["strDescriptionCN"].str).length == 0 ? "null" :i["strDescriptionCN"].str,
                    i["strDescriptionIT"].isNull() ? i["strDescriptionIT"].toString : strip(i["strDescriptionIT"].str).length == 0 ? "null" :i["strDescriptionIT"].str,
                    i["strDescriptionJP"].isNull() ? i["strDescriptionJP"].toString : strip(i["strDescriptionJP"].str).length == 0 ? "null" :i["strDescriptionJP"].str,
                    i["strDescriptionRU"].isNull() ? i["strDescriptionRU"].toString : strip(i["strDescriptionRU"].str).length == 0 ? "null" :i["strDescriptionRU"].str,
                    i["strDescriptionES"].isNull() ? i["strDescriptionES"].toString : strip(i["strDescriptionES"].str).length == 0 ? "null" :i["strDescriptionES"].str,
                    i["strDescriptionPT"].isNull() ? i["strDescriptionPT"].toString : strip(i["strDescriptionPT"].str).length == 0 ? "null" :i["strDescriptionPT"].str,
                    i["strDescriptionSE"].isNull() ? i["strDescriptionSE"].toString : strip(i["strDescriptionSE"].str).length == 0 ? "null" :i["strDescriptionSE"].str,
                    i["strDescriptionNL"].isNull() ? i["strDescriptionNL"].toString : strip(i["strDescriptionNL"].str).length == 0 ? "null" :i["strDescriptionNL"].str,
                    i["strDescriptionHU"].isNull() ? i["strDescriptionHU"].toString : strip(i["strDescriptionHU"].str).length == 0 ? "null" :i["strDescriptionHU"].str,
                    i["strDescriptionNO"].isNull() ? i["strDescriptionNO"].toString : strip(i["strDescriptionNO"].str).length == 0 ? "null" :i["strDescriptionNO"].str,
                    i["strDescriptionIL"].isNull() ? i["strDescriptionIL"].toString : strip(i["strDescriptionIL"].str).length == 0 ? "null" :i["strDescriptionIL"].str,
                    i["strDescriptionPL"].isNull() ? i["strDescriptionPL"].toString : strip(i["strDescriptionPL"].str).length == 0 ? "null" :i["strDescriptionPL"].str,
                    i["intLoved"].isNull() ? i["intLoved"].toString : strip(i["intLoved"].str).length == 0 ? "null" :i["intLoved"].str,
                    i["intScore"].isNull() ? i["intScore"].toString : strip(i["intScore"].str).length == 0 ? "null" :i["intScore"].str,
                    i["intScoreVotes"].isNull() ? i["intScoreVotes"].toString : strip(i["intScoreVotes"].str).length == 0 ? "null" :i["intScoreVotes"].str,
                    i["strReview"].isNull() ? i["strReview"].toString : strip(i["strReview"].str).length == 0 ? "null" :i["strReview"].str,
                    i["strMood"].isNull() ? i["strMood"].toString : strip(i["strMood"].str).length == 0 ? "null" :i["strMood"].str,
                    i["strTheme"].isNull() ? i["strTheme"].toString : strip(i["strTheme"].str).length == 0 ? "null" :i["strTheme"].str,
                    i["strSpeed"].isNull() ? i["strSpeed"].toString : strip(i["strSpeed"].str).length == 0 ? "null" :i["strSpeed"].str,
                    i["strLocation"].isNull() ? i["strLocation"].toString : strip(i["strLocation"].str).length == 0 ? "null" :i["strLocation"].str,
                    i["strMusicBrainzID"].isNull() ? i["strMusicBrainzID"].toString : strip(i["strMusicBrainzID"].str).length == 0 ? "null" :i["strMusicBrainzID"].str,
                    i["strMusicBrainzArtistID"].isNull() ? i["strMusicBrainzArtistID"].toString : strip(i["strMusicBrainzArtistID"].str).length == 0 ? "null" :i["strMusicBrainzArtistID"].str,
                    i["strAllMusicID"].isNull() ? i["strAllMusicID"].toString : strip(i["strAllMusicID"].str).length == 0 ? "null" :i["strAllMusicID"].str,
                    i["strBBCReviewID"].isNull() ? i["strBBCReviewID"].toString : strip(i["strBBCReviewID"].str).length == 0 ? "null" :i["strBBCReviewID"].str,
                    i["strRateYourMusicID"].isNull() ? i["strRateYourMusicID"].toString : strip(i["strRateYourMusicID"].str).length == 0 ? "null" :i["strRateYourMusicID"].str,
                    i["strDiscogsID"].isNull() ? i["strDiscogsID"].toString : strip(i["strDiscogsID"].str).length == 0 ? "null" :i["strDiscogsID"].str,
                    i["strWikidataID"].isNull() ? i["strWikidataID"].toString : strip(i["strWikidataID"].str).length == 0 ? "null" :i["strWikidataID"].str,
                    i["strWikipediaID"].isNull() ? i["strWikipediaID"].toString : strip(i["strWikipediaID"].str).length == 0 ? "null" :i["strWikipediaID"].str,
                    i["strGeniusID"].isNull() ? i["strGeniusID"].toString : strip(i["strGeniusID"].str).length == 0 ? "null" :i["strGeniusID"].str,
                    i["strLyricWikiID"].isNull() ? i["strLyricWikiID"].toString : strip(i["strLyricWikiID"].str).length == 0 ? "null" :i["strLyricWikiID"].str,
                    i["strMusicMozID"].isNull() ? i["strMusicMozID"].toString : strip(i["strMusicMozID"].str).length == 0 ? "null" :i["strMusicMozID"].str,
                    i["strItunesID"].isNull() ? i["strItunesID"].toString : strip(i["strItunesID"].str).length == 0 ? "null" :i["strItunesID"].str,
                    i["strAmazonID"].isNull() ? i["strAmazonID"].toString : strip(i["strAmazonID"].str).length == 0 ? "null" :i["strAmazonID"].str,
                    i["strLocked"].isNull() ? i["strLocked"].toString : strip(i["strLocked"].str).length == 0 ? "null" :i["strLocked"].str,
                };
                array ~= data;
            }
            return array;
        }
        throw new Exception("no results found");
    }
    catch(CurlException ex)
    {
        throw new AudioDBException(ex.msg);
    }
    catch(JSONException ex)
    {
        throw new AudioDBException(format("Something went wrong while parsing json: %s", ex.msg));
    }
    catch(Exception ex)
    {
        throw new AudioDBException(ex.msg);
    }
}

/** 
 * Params:
 *   l
 * Returns: All Tracks for Album from known Album ID
 * Throws: AudioDBException on failure
 */
Track[] searchTracksByAlbumId(long l) {
    try
    {
        auto response = getRequest(format("track.php?m=%d", l));
        if (response.length == 0)
        {
            throw new Exception("no results found");
        }
        JSONValue json = parseJSON(response); 
        if (json["track"].type != JSONType.null_ && json["track"].array.length != 0) {
            Track[] array = [];
            foreach(ref i; json["track"].array)
            {
                Track data = {
                    i["idTrack"].isNull() ? i["idTrack"].toString : strip(i["idTrack"].str).length == 0 ? "null" :i["idTrack"].str,
                    i["idAlbum"].isNull() ? i["idAlbum"].toString : strip(i["idAlbum"].str).length == 0 ? "null" :i["idAlbum"].str,
                    i["idArtist"].isNull() ? i["idArtist"].toString : strip(i["idArtist"].str).length == 0 ? "null" :i["idArtist"].str,
                    i["idLyric"].isNull() ? i["idLyric"].toString : strip(i["idLyric"].str).length == 0 ? "null" :i["idLyric"].str,
                    i["idIMVDB"].isNull() ? i["idIMVDB"].toString : strip(i["idIMVDB"].str).length == 0 ? "null" :i["idIMVDB"].str,
                    i["strTrack"].isNull() ? i["strTrack"].toString : strip(i["strTrack"].str).length == 0 ? "null" :i["strTrack"].str,
                    i["strAlbum"].isNull() ? i["strAlbum"].toString : strip(i["strAlbum"].str).length == 0 ? "null" :i["strAlbum"].str,
                    i["strArtist"].isNull() ? i["strArtist"].toString : strip(i["strArtist"].str).length == 0 ? "null" :i["strArtist"].str,
                    i["strArtistAlternate"].isNull() ? i["strArtistAlternate"].toString : strip(i["strArtistAlternate"].str).length == 0 ? "null" :i["strArtistAlternate"].str,
                    i["intCD"].isNull() ? i["intCD"].toString : strip(i["intCD"].str).length == 0 ? "null" :i["intCD"].str,
                    i["intDuration"].isNull() ? i["intDuration"].toString : strip(i["intDuration"].str).length == 0 ? "null" :i["intDuration"].str,
                    i["strGenre"].isNull() ? i["strGenre"].toString : strip(i["strGenre"].str).length == 0 ? "null" :i["strGenre"].str,
                    i["strMood"].isNull() ? i["strMood"].toString : strip(i["strMood"].str).length == 0 ? "null" :i["strMood"].str,
                    i["strStyle"].isNull() ? i["strStyle"].toString : strip(i["strStyle"].str).length == 0 ? "null" :i["strStyle"].str,
                    i["strTheme"].isNull() ? i["strTheme"].toString : strip(i["strTheme"].str).length == 0 ? "null" :i["strTheme"].str,
                    i["strDescriptionEN"].isNull() ? i["strDescriptionEN"].toString : strip(i["strDescriptionEN"].str).length == 0 ? "null" :i["strDescriptionEN"].str,
                    i["strDescriptionDE"].isNull() ? i["strDescriptionDE"].toString : strip(i["strDescriptionDE"].str).length == 0 ? "null" :i["strDescriptionDE"].str,
                    i["strDescriptionFR"].isNull() ? i["strDescriptionFR"].toString : strip(i["strDescriptionFR"].str).length == 0 ? "null" :i["strDescriptionFR"].str,
                    i["strDescriptionCN"].isNull() ? i["strDescriptionCN"].toString : strip(i["strDescriptionCN"].str).length == 0 ? "null" :i["strDescriptionCN"].str,
                    i["strDescriptionIT"].isNull() ? i["strDescriptionIT"].toString : strip(i["strDescriptionIT"].str).length == 0 ? "null" :i["strDescriptionIT"].str,
                    i["strDescriptionJP"].isNull() ? i["strDescriptionJP"].toString : strip(i["strDescriptionJP"].str).length == 0 ? "null" :i["strDescriptionJP"].str,
                    i["strDescriptionRU"].isNull() ? i["strDescriptionRU"].toString : strip(i["strDescriptionRU"].str).length == 0 ? "null" :i["strDescriptionRU"].str,
                    i["strDescriptionES"].isNull() ? i["strDescriptionES"].toString : strip(i["strDescriptionES"].str).length == 0 ? "null" :i["strDescriptionES"].str,
                    i["strDescriptionPT"].isNull() ? i["strDescriptionPT"].toString : strip(i["strDescriptionPT"].str).length == 0 ? "null" :i["strDescriptionPT"].str,
                    i["strDescriptionSE"].isNull() ? i["strDescriptionSE"].toString : strip(i["strDescriptionSE"].str).length == 0 ? "null" :i["strDescriptionSE"].str,
                    i["strDescriptionNL"].isNull() ? i["strDescriptionNL"].toString : strip(i["strDescriptionNL"].str).length == 0 ? "null" :i["strDescriptionNL"].str,
                    i["strDescriptionHU"].isNull() ? i["strDescriptionHU"].toString : strip(i["strDescriptionHU"].str).length == 0 ? "null" :i["strDescriptionHU"].str,
                    i["strDescriptionNO"].isNull() ? i["strDescriptionNO"].toString : strip(i["strDescriptionNO"].str).length == 0 ? "null" :i["strDescriptionNO"].str,
                    i["strDescriptionIL"].isNull() ? i["strDescriptionIL"].toString : strip(i["strDescriptionIL"].str).length == 0 ? "null" :i["strDescriptionIL"].str,
                    i["strDescriptionPL"].isNull() ? i["strDescriptionPL"].toString : strip(i["strDescriptionPL"].str).length == 0 ? "null" :i["strDescriptionPL"].str,
                    i["strTrackThumb"].isNull() ? i["strTrackThumb"].toString : strip(i["strTrackThumb"].str).length == 0 ? "null" :i["strTrackThumb"].str,
                    i["strTrack3DCase"].isNull() ? i["strTrack3DCase"].toString : strip(i["strTrack3DCase"].str).length == 0 ? "null" :i["strTrack3DCase"].str,
                    i["strTrackLyrics"].isNull() ? i["strTrackLyrics"].toString : strip(i["strTrackLyrics"].str).length == 0 ? "null" :i["strTrackLyrics"].str,
                    i["strMusicVid"].isNull() ? i["strMusicVid"].toString : strip(i["strMusicVid"].str).length == 0 ? "null" :i["strMusicVid"].str,
                    i["strMusicVidDirector"].isNull() ? i["strMusicVidDirector"].toString : strip(i["strMusicVidDirector"].str).length == 0 ? "null" :i["strMusicVidDirector"].str,
                    i["strMusicVidCompany"].isNull() ? i["strMusicVidCompany"].toString : strip(i["strMusicVidCompany"].str).length == 0 ? "null" :i["strMusicVidCompany"].str,
                    i["strMusicVidScreen1"].isNull() ? i["strMusicVidScreen1"].toString : strip(i["strMusicVidScreen1"].str).length == 0 ? "null" :i["strMusicVidScreen1"].str,
                    i["strMusicVidScreen2"].isNull() ? i["strMusicVidScreen2"].toString : strip(i["strMusicVidScreen2"].str).length == 0 ? "null" :i["strMusicVidScreen2"].str,
                    i["strMusicVidScreen3"].isNull() ? i["strMusicVidScreen3"].toString : strip(i["strMusicVidScreen3"].str).length == 0 ? "null" :i["strMusicVidScreen3"].str,
                    i["intMusicVidViews"].isNull() ? i["intMusicVidViews"].toString : strip(i["intMusicVidViews"].str).length == 0 ? "null" :i["intMusicVidViews"].str,
                    i["intMusicVidLikes"].isNull() ? i["intMusicVidLikes"].toString : strip(i["intMusicVidLikes"].str).length == 0 ? "null" :i["intMusicVidLikes"].str,
                    i["intMusicVidDislikes"].isNull() ? i["intMusicVidDislikes"].toString : strip(i["intMusicVidDislikes"].str).length == 0 ? "null" :i["intMusicVidDislikes"].str,
                    i["intMusicVidFavorites"].isNull() ? i["intMusicVidFavorites"].toString : strip(i["intMusicVidFavorites"].str).length == 0 ? "null" :i["intMusicVidFavorites"].str,
                    i["intMusicVidComments"].isNull() ? i["intMusicVidComments"].toString : strip(i["intMusicVidComments"].str).length == 0 ? "null" :i["intMusicVidComments"].str,
                    i["intTrackNumber"].isNull() ? i["intTrackNumber"].toString : strip(i["intTrackNumber"].str).length == 0 ? "null" :i["intTrackNumber"].str,
                    i["intLoved"].isNull() ? i["intLoved"].toString : strip(i["intLoved"].str).length == 0 ? "null" :i["intLoved"].str,
                    i["intScore"].isNull() ? i["intScore"].toString : strip(i["intScore"].str).length == 0 ? "null" :i["intScore"].str,
                    i["intScoreVotes"].isNull() ? i["intScoreVotes"].toString : strip(i["intScoreVotes"].str).length == 0 ? "null" :i["intScoreVotes"].str,
                    i["intTotalListeners"].isNull() ? i["intTotalListeners"].toString : strip(i["intTotalListeners"].str).length == 0 ? "null" :i["intTotalListeners"].str,
                    i["intTotalPlays"].isNull() ? i["intTotalPlays"].toString : strip(i["intTotalPlays"].str).length == 0 ? "null" :i["intTotalPlays"].str,
                    i["strMusicBrainzID"].isNull() ? i["strMusicBrainzID"].toString : strip(i["strMusicBrainzID"].str).length == 0 ? "null" :i["strMusicBrainzID"].str,
                    i["strMusicBrainzAlbumID"].isNull() ? i["strMusicBrainzAlbumID"].toString : strip(i["strMusicBrainzAlbumID"].str).length == 0 ? "null" :i["strMusicBrainzAlbumID"].str,
                    i["strMusicBrainzArtistID"].isNull() ? i["strMusicBrainzArtistID"].toString : strip(i["strMusicBrainzArtistID"].str).length == 0 ? "null" :i["strMusicBrainzArtistID"].str,
                    i["strLocked"].isNull() ? i["strLocked"].toString : strip(i["strLocked"].str).length == 0 ? "null" :i["strLocked"].str,
                };
                array ~= data;
            }
            return array;
        }
        throw new Exception("no results found");
    }
    catch(CurlException ex)
    {
        throw new AudioDBException(ex.msg);
    }
    catch(JSONException ex)
    {
        throw new AudioDBException(format("Something went wrong while parsing json: %s", ex.msg));
    }
    catch(Exception ex)
    {
        throw new AudioDBException(ex.msg);
    }
}

/** 
 * Params:
 *   l
 * Returns: individual track info using a known Track ID
 * Throws: AudioDBException on failure
 */
Track searchTrackById(long l) {
    try
    {
        auto response = getRequest(format("track.php?h=%d", l));
        if (response.length == 0)
        {
            throw new Exception("no results found");
        }
        JSONValue json = parseJSON(response); 
        if (json["track"].type != JSONType.null_ && json["track"].array.length != 0) {
            Track data = {
                json["track"][0]["idTrack"].isNull() ? json["track"][0]["idTrack"].toString : strip(json["track"][0]["idTrack"].str).length == 0 ? "null" :json["track"][0]["idTrack"].str,
                json["track"][0]["idAlbum"].isNull() ? json["track"][0]["idAlbum"].toString : strip(json["track"][0]["idAlbum"].str).length == 0 ? "null" :json["track"][0]["idAlbum"].str,
                json["track"][0]["idArtist"].isNull() ? json["track"][0]["idArtist"].toString : strip(json["track"][0]["idArtist"].str).length == 0 ? "null" :json["track"][0]["idArtist"].str,
                json["track"][0]["idLyric"].isNull() ? json["track"][0]["idLyric"].toString : strip(json["track"][0]["idLyric"].str).length == 0 ? "null" :json["track"][0]["idLyric"].str,
                json["track"][0]["idIMVDB"].isNull() ? json["track"][0]["idIMVDB"].toString : strip(json["track"][0]["idIMVDB"].str).length == 0 ? "null" :json["track"][0]["idIMVDB"].str,
                json["track"][0]["strTrack"].isNull() ? json["track"][0]["strTrack"].toString : strip(json["track"][0]["strTrack"].str).length == 0 ? "null" :json["track"][0]["strTrack"].str,
                json["track"][0]["strAlbum"].isNull() ? json["track"][0]["strAlbum"].toString : strip(json["track"][0]["strAlbum"].str).length == 0 ? "null" :json["track"][0]["strAlbum"].str,
                json["track"][0]["strArtist"].isNull() ? json["track"][0]["strArtist"].toString : strip(json["track"][0]["strArtist"].str).length == 0 ? "null" :json["track"][0]["strArtist"].str,
                json["track"][0]["strArtistAlternate"].isNull() ? json["track"][0]["strArtistAlternate"].toString : strip(json["track"][0]["strArtistAlternate"].str).length == 0 ? "null" :json["track"][0]["strArtistAlternate"].str,
                json["track"][0]["intCD"].isNull() ? json["track"][0]["intCD"].toString : strip(json["track"][0]["intCD"].str).length == 0 ? "null" :json["track"][0]["intCD"].str,
                json["track"][0]["intDuration"].isNull() ? json["track"][0]["intDuration"].toString : strip(json["track"][0]["intDuration"].str).length == 0 ? "null" :json["track"][0]["intDuration"].str,
                json["track"][0]["strGenre"].isNull() ? json["track"][0]["strGenre"].toString : strip(json["track"][0]["strGenre"].str).length == 0 ? "null" :json["track"][0]["strGenre"].str,
                json["track"][0]["strMood"].isNull() ? json["track"][0]["strMood"].toString : strip(json["track"][0]["strMood"].str).length == 0 ? "null" :json["track"][0]["strMood"].str,
                json["track"][0]["strStyle"].isNull() ? json["track"][0]["strStyle"].toString : strip(json["track"][0]["strStyle"].str).length == 0 ? "null" :json["track"][0]["strStyle"].str,
                json["track"][0]["strTheme"].isNull() ? json["track"][0]["strTheme"].toString : strip(json["track"][0]["strTheme"].str).length == 0 ? "null" :json["track"][0]["strTheme"].str,
                json["track"][0]["strDescriptionEN"].isNull() ? json["track"][0]["strDescriptionEN"].toString : strip(json["track"][0]["strDescriptionEN"].str).length == 0 ? "null" :json["track"][0]["strDescriptionEN"].str,
                json["track"][0]["strDescriptionDE"].isNull() ? json["track"][0]["strDescriptionDE"].toString : strip(json["track"][0]["strDescriptionDE"].str).length == 0 ? "null" :json["track"][0]["strDescriptionDE"].str,
                json["track"][0]["strDescriptionFR"].isNull() ? json["track"][0]["strDescriptionFR"].toString : strip(json["track"][0]["strDescriptionFR"].str).length == 0 ? "null" :json["track"][0]["strDescriptionFR"].str,
                json["track"][0]["strDescriptionCN"].isNull() ? json["track"][0]["strDescriptionCN"].toString : strip(json["track"][0]["strDescriptionCN"].str).length == 0 ? "null" :json["track"][0]["strDescriptionCN"].str,
                json["track"][0]["strDescriptionIT"].isNull() ? json["track"][0]["strDescriptionIT"].toString : strip(json["track"][0]["strDescriptionIT"].str).length == 0 ? "null" :json["track"][0]["strDescriptionIT"].str,
                json["track"][0]["strDescriptionJP"].isNull() ? json["track"][0]["strDescriptionJP"].toString : strip(json["track"][0]["strDescriptionJP"].str).length == 0 ? "null" :json["track"][0]["strDescriptionJP"].str,
                json["track"][0]["strDescriptionRU"].isNull() ? json["track"][0]["strDescriptionRU"].toString : strip(json["track"][0]["strDescriptionRU"].str).length == 0 ? "null" :json["track"][0]["strDescriptionRU"].str,
                json["track"][0]["strDescriptionES"].isNull() ? json["track"][0]["strDescriptionES"].toString : strip(json["track"][0]["strDescriptionES"].str).length == 0 ? "null" :json["track"][0]["strDescriptionES"].str,
                json["track"][0]["strDescriptionPT"].isNull() ? json["track"][0]["strDescriptionPT"].toString : strip(json["track"][0]["strDescriptionPT"].str).length == 0 ? "null" :json["track"][0]["strDescriptionPT"].str,
                json["track"][0]["strDescriptionSE"].isNull() ? json["track"][0]["strDescriptionSE"].toString : strip(json["track"][0]["strDescriptionSE"].str).length == 0 ? "null" :json["track"][0]["strDescriptionSE"].str,
                json["track"][0]["strDescriptionNL"].isNull() ? json["track"][0]["strDescriptionNL"].toString : strip(json["track"][0]["strDescriptionNL"].str).length == 0 ? "null" :json["track"][0]["strDescriptionNL"].str,
                json["track"][0]["strDescriptionHU"].isNull() ? json["track"][0]["strDescriptionHU"].toString : strip(json["track"][0]["strDescriptionHU"].str).length == 0 ? "null" :json["track"][0]["strDescriptionHU"].str,
                json["track"][0]["strDescriptionNO"].isNull() ? json["track"][0]["strDescriptionNO"].toString : strip(json["track"][0]["strDescriptionNO"].str).length == 0 ? "null" :json["track"][0]["strDescriptionNO"].str,
                json["track"][0]["strDescriptionIL"].isNull() ? json["track"][0]["strDescriptionIL"].toString : strip(json["track"][0]["strDescriptionIL"].str).length == 0 ? "null" :json["track"][0]["strDescriptionIL"].str,
                json["track"][0]["strDescriptionPL"].isNull() ? json["track"][0]["strDescriptionPL"].toString : strip(json["track"][0]["strDescriptionPL"].str).length == 0 ? "null" :json["track"][0]["strDescriptionPL"].str,
                json["track"][0]["strTrackThumb"].isNull() ? json["track"][0]["strTrackThumb"].toString : strip(json["track"][0]["strTrackThumb"].str).length == 0 ? "null" :json["track"][0]["strTrackThumb"].str,
                json["track"][0]["strTrack3DCase"].isNull() ? json["track"][0]["strTrack3DCase"].toString : strip(json["track"][0]["strTrack3DCase"].str).length == 0 ? "null" :json["track"][0]["strTrack3DCase"].str,
                json["track"][0]["strTrackLyrics"].isNull() ? json["track"][0]["strTrackLyrics"].toString : strip(json["track"][0]["strTrackLyrics"].str).length == 0 ? "null" :json["track"][0]["strTrackLyrics"].str,
                json["track"][0]["strMusicVid"].isNull() ? json["track"][0]["strMusicVid"].toString : strip(json["track"][0]["strMusicVid"].str).length == 0 ? "null" :json["track"][0]["strMusicVid"].str,
                json["track"][0]["strMusicVidDirector"].isNull() ? json["track"][0]["strMusicVidDirector"].toString : strip(json["track"][0]["strMusicVidDirector"].str).length == 0 ? "null" :json["track"][0]["strMusicVidDirector"].str,
                json["track"][0]["strMusicVidCompany"].isNull() ? json["track"][0]["strMusicVidCompany"].toString : strip(json["track"][0]["strMusicVidCompany"].str).length == 0 ? "null" :json["track"][0]["strMusicVidCompany"].str,
                json["track"][0]["strMusicVidScreen1"].isNull() ? json["track"][0]["strMusicVidScreen1"].toString : strip(json["track"][0]["strMusicVidScreen1"].str).length == 0 ? "null" :json["track"][0]["strMusicVidScreen1"].str,
                json["track"][0]["strMusicVidScreen2"].isNull() ? json["track"][0]["strMusicVidScreen2"].toString : strip(json["track"][0]["strMusicVidScreen2"].str).length == 0 ? "null" :json["track"][0]["strMusicVidScreen2"].str,
                json["track"][0]["strMusicVidScreen3"].isNull() ? json["track"][0]["strMusicVidScreen3"].toString : strip(json["track"][0]["strMusicVidScreen3"].str).length == 0 ? "null" :json["track"][0]["strMusicVidScreen3"].str,
                json["track"][0]["intMusicVidViews"].isNull() ? json["track"][0]["intMusicVidViews"].toString : strip(json["track"][0]["intMusicVidViews"].str).length == 0 ? "null" :json["track"][0]["intMusicVidViews"].str,
                json["track"][0]["intMusicVidLikes"].isNull() ? json["track"][0]["intMusicVidLikes"].toString : strip(json["track"][0]["intMusicVidLikes"].str).length == 0 ? "null" :json["track"][0]["intMusicVidLikes"].str,
                json["track"][0]["intMusicVidDislikes"].isNull() ? json["track"][0]["intMusicVidDislikes"].toString : strip(json["track"][0]["intMusicVidDislikes"].str).length == 0 ? "null" :json["track"][0]["intMusicVidDislikes"].str,
                json["track"][0]["intMusicVidFavorites"].isNull() ? json["track"][0]["intMusicVidFavorites"].toString : strip(json["track"][0]["intMusicVidFavorites"].str).length == 0 ? "null" :json["track"][0]["intMusicVidFavorites"].str,
                json["track"][0]["intMusicVidComments"].isNull() ? json["track"][0]["intMusicVidComments"].toString : strip(json["track"][0]["intMusicVidComments"].str).length == 0 ? "null" :json["track"][0]["intMusicVidComments"].str,
                json["track"][0]["intTrackNumber"].isNull() ? json["track"][0]["intTrackNumber"].toString : strip(json["track"][0]["intTrackNumber"].str).length == 0 ? "null" :json["track"][0]["intTrackNumber"].str,
                json["track"][0]["intLoved"].isNull() ? json["track"][0]["intLoved"].toString : strip(json["track"][0]["intLoved"].str).length == 0 ? "null" :json["track"][0]["intLoved"].str,
                json["track"][0]["intScore"].isNull() ? json["track"][0]["intScore"].toString : strip(json["track"][0]["intScore"].str).length == 0 ? "null" :json["track"][0]["intScore"].str,
                json["track"][0]["intScoreVotes"].isNull() ? json["track"][0]["intScoreVotes"].toString : strip(json["track"][0]["intScoreVotes"].str).length == 0 ? "null" :json["track"][0]["intScoreVotes"].str,
                json["track"][0]["intTotalListeners"].isNull() ? json["track"][0]["intTotalListeners"].toString : strip(json["track"][0]["intTotalListeners"].str).length == 0 ? "null" :json["track"][0]["intTotalListeners"].str,
                json["track"][0]["intTotalPlays"].isNull() ? json["track"][0]["intTotalPlays"].toString : strip(json["track"][0]["intTotalPlays"].str).length == 0 ? "null" :json["track"][0]["intTotalPlays"].str,
                json["track"][0]["strMusicBrainzID"].isNull() ? json["track"][0]["strMusicBrainzID"].toString : strip(json["track"][0]["strMusicBrainzID"].str).length == 0 ? "null" :json["track"][0]["strMusicBrainzID"].str,
                json["track"][0]["strMusicBrainzAlbumID"].isNull() ? json["track"][0]["strMusicBrainzAlbumID"].toString : strip(json["track"][0]["strMusicBrainzAlbumID"].str).length == 0 ? "null" :json["track"][0]["strMusicBrainzAlbumID"].str,
                json["track"][0]["strMusicBrainzArtistID"].isNull() ? json["track"][0]["strMusicBrainzArtistID"].toString : strip(json["track"][0]["strMusicBrainzArtistID"].str).length == 0 ? "null" :json["track"][0]["strMusicBrainzArtistID"].str,
                json["track"][0]["strLocked"].isNull() ? json["track"][0]["strLocked"].toString : strip(json["track"][0]["strLocked"].str).length == 0 ? "null" :json["track"][0]["strLocked"].str,
            };
            return data;
        }
        throw new Exception("no results found");
    }
    catch(CurlException ex)
    {
        throw new AudioDBException(ex.msg);
    }
    catch(JSONException ex)
    {
        throw new AudioDBException(format("Something went wrong while parsing json: %s", ex.msg));
    }
    catch(Exception ex)
    {
        throw new AudioDBException(ex.msg);
    }
}

/** 
 * Params:
 *   l
 * Returns: all the Music videos for a known Artist ID
 * Throws: AudioDBException on failure
 */
MusicVideo[] searchMusicVideosByArtistId(long l) {
    try
    {
        auto response = getRequest(format("mvid.php?i=%d", l));
        if (response.length == 0)
        {
            throw new Exception("no results found");
        }
        JSONValue json = parseJSON(response); 
        if (json["mvids"].type != JSONType.null_ && json["mvids"].array.length != 0) {
            MusicVideo[] array = [];
            foreach(ref i; json["mvids"].array)
            {
                MusicVideo data = {
                    i["idArtist"].isNull() ? i["idArtist"].toString : strip(i["idArtist"].str).length == 0 ? "null" : i["idArtist"].str,
                    i["idAlbum"].isNull() ? i["idAlbum"].toString : strip(i["idAlbum"].str).length == 0 ? "null" : i["idAlbum"].str,
                    i["idTrack"].isNull() ? i["idTrack"].toString : strip(i["idTrack"].str).length == 0 ? "null" : i["idTrack"].str,
                    i["strTrack"].isNull() ? i["strTrack"].toString : strip(i["strTrack"].str).length == 0 ? "null" : i["strTrack"].str,
                    i["strTrackThumb"].isNull() ? i["strTrackThumb"].toString : strip(i["strTrackThumb"].str).length == 0 ? "null" : i["strTrackThumb"].str,
                    i["strMusicVid"].isNull() ? i["strMusicVid"].toString : strip(i["strMusicVid"].str).length == 0 ? "null" : i["strMusicVid"].str,
                    i["strDescriptionEN"].isNull() ? i["strDescriptionEN"].toString : strip(i["strDescriptionEN"].str).length == 0 ? "null" : i["strDescriptionEN"].str,
                };
                array ~= data;
            }
            return array;
        }
        throw new Exception("no results found");
    }
    catch(CurlException ex)
    {
        throw new AudioDBException(ex.msg);
    }
    catch(JSONException ex)
    {
        throw new AudioDBException(format("Something went wrong while parsing json: %s", ex.msg));
    }
    catch(Exception ex)
    {
        throw new AudioDBException(ex.msg);
    }
}