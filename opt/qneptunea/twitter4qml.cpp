/* Copyright (c) 2012-2013 QNeptunea Project.
 * All rights reserved.
 * 
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *     * Redistributions of source code must retain the above copyright
 *       notice, this list of conditions and the following disclaimer.
 *     * Redistributions in binary form must reproduce the above copyright
 *       notice, this list of conditions and the following disclaimer in the
 *       documentation and/or other materials provided with the distribution.
 *     * Neither the name of the QNeptunea nor the
 *       names of its contributors may be used to endorse or promote products
 *       derived from this software without specific prior written permission.
 * 
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL QNEPTUNEA BE LIABLE FOR ANY
 * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#include "twitter4qml.h"
#if QT_VERSION >= 0x050000
#include <QtQml/qqml.h>
#else
#include <QtDeclarative/qdeclarative.h>
#endif

// Timelines
#include <mentionstimeline.h>
#include <hometimeline.h>
#include <usertimeline.h>
#include <retweetsofme.h>

// Tweets
#include <retweets.h>
#include <status.h>

// Search
#include <search.h>

// Streaming
#include <userstream.h>
#include <filterstream.h>

// Direct Messages
#include <directmessages.h>
#include <directmessagessent.h>
#include <directmessage.h>

// Friends & Followers
#include <noretweetids.h>
#include <followerids.h>
#include <friendids.h>
#include <incoming.h>
#include <outgoing.h>
#include <followers.h>
#include <friends.h>
#include <showfriendships.h>

// Users
#include <settings.h>
#include <verifycredentials.h>
#include <updatesettings.h>
#include <updateprofile.h>
#include <blocklist.h>
#include <blockids.h>
#include <lookupusers.h>
#include <user.h>
#include <searchusers.h>

// Suggested Users
#include <slugs.h>
#include <suggestions.h>

// Favorites
#include <favoriteslist.h>

// Lists
#include <lists.h>
#include <liststatuses.h>
#include <listsmemberships.h>
#include <listmembers.h>
#include <listssubscriptions.h>
#include <list.h> // TODO ?

// Saved Searches
#include <savedsearches.h>

// Places & Geo
#include <reversegeocode.h>
#include <geosearch.h>

// Trends
#include <place.h>
#include <available.h>

// Spam Reporting

// OAuth
#include <oauth.h>

// Help
#include <configuration.h>
#include <languages.h>
#include <privacy.h>
#include <tos.h>
#include <ratelimitstatus.h>

#include <oauthmanager.h>

#include <related_results/showrelatedresults.h>
#include <activitysummary.h>

Twitter4QML::Twitter4QML(QObject *parent)
    : QObject(parent)
{
    int major = 1;
    int minor = 1;

    qmlRegisterUncreatableType<Twitter4QML>("Twitter4QML", major, minor, "Twitter4QML", "access twitter4qml directly.");

    // REST API v1.1 Resources
    // https://dev.twitter.com/docs/api/1.1

    // Timelines
    qmlRegisterType<MentionsTimeline>("Twitter4QML", major, minor, "MentionsTimelineModel");
    qmlRegisterType<UserTimeline>("Twitter4QML", major, minor, "UserTimelineModel");
    qmlRegisterType<HomeTimeline>("Twitter4QML", major, minor, "HomeTimelineModel");
    qmlRegisterType<RetweetsOfMe>("Twitter4QML", major, minor, "RetweetsOfMeModel");

    // Tweets
    qmlRegisterType<Retweets>("Twitter4QML", major, minor, "RetweetsModel");
    qmlRegisterType<Status>("Twitter4QML", major, minor, "Status");

    // Search
    qmlRegisterType<Search>("Twitter4QML", major, minor, "SearchModel");

    // Streaming
    qmlRegisterType<UserStream>("Twitter4QML", major, minor, "UserStreamModel");
    qmlRegisterType<FilterStream>("Twitter4QML", major, minor, "FilterStreamModel");

    // Direct Messages
    qmlRegisterType<DirectMessages>("Twitter4QML", major, minor, "DirectMessagesModel");
    qmlRegisterType<DirectMessagesSent>("Twitter4QML", major, minor, "DirectMessagesSentModel");
    qmlRegisterType<DirectMessage>("Twitter4QML", major, minor, "DirectMessage");

    // Friends & Followers
    qmlRegisterType<NoRetweetIds>("Twitter4QML", major, minor, "NoRetweetIdsModel");
    qmlRegisterType<FriendIds>("Twitter4QML", major, minor, "FriendIdsModel");
    qmlRegisterType<FollowerIds>("Twitter4QML", major, minor, "FollowerIdsModel");
    qmlRegisterType<Incoming>("Twitter4QML", major, minor, "IncomingModel");
    qmlRegisterType<Outgoing>("Twitter4QML", major, minor, "OutgoingModel");
    qmlRegisterType<ShowFriendships>("Twitter4QML", major, minor, "ShowFriendships");
    qmlRegisterType<Friends>("Twitter4QML", major, minor, "FriendsModel");
    qmlRegisterType<Followers>("Twitter4QML", major, minor, "FollowersModel");



    qmlRegisterType<LookupUsers>("Twitter4QML", major, minor, "UsersModel");
    qmlRegisterType<User>("Twitter4QML", major, minor, "User");
    qmlRegisterType<Slugs>("Twitter4QML", major, minor, "SlugsModel");
    qmlRegisterType<Suggestions>("Twitter4QML", major, minor, "SuggestionsModel");
    qmlRegisterType<SearchUsers>("Twitter4QML", major, minor, "SearchUsersModel");

    qmlRegisterType<FavoritesList>("Twitter4QML", major, minor, "FavoritesModel");

    qmlRegisterType<Lists>("Twitter4QML", major, minor, "ListsModel");
    qmlRegisterType<ListsSubscriptions>("Twitter4QML", major, minor, "ListsSubscriptionsModel");
    qmlRegisterType<ListsMemberships>("Twitter4QML", major, minor, "ListsMembershipsModel");
    qmlRegisterType<ListStatuses>("Twitter4QML", major, minor, "ListStatusesModel");
    qmlRegisterType<ListMembers>("Twitter4QML", major, minor, "ListMembersModel");
    qmlRegisterType<List>("Twitter4QML", major, minor, "List");

    qmlRegisterType<VerifyCredentials>("Twitter4QML", major, minor, "VerifyCredentials");
    qmlRegisterType<UpdateProfile>("Twitter4QML", major, minor, "UpdateProfile");
    qmlRegisterType<Settings>("Twitter4QML", major, minor, "Settings");
    qmlRegisterType<RateLimitStatus>("Twitter4QML", major, minor, "RateLimitStatus");

    qmlRegisterType<SavedSearches>("Twitter4QML", major, minor, "SavedSearchesModel");

    qmlRegisterType<GeoSearch>("Twitter4QML", major, minor, "GeoSearchModel");
    qmlRegisterType<ReverseGeocode>("Twitter4QML", major, minor, "ReverseGeocodeModel");

    qmlRegisterType<Place>("Twitter4QML", major, minor, "TrendsPlaceModel");
    qmlRegisterType<Available>("Twitter4QML", major, minor, "TrendsAvailableModel");

    qmlRegisterType<OAuth>("Twitter4QML", major, minor, "OAuth");

    qmlRegisterType<Configuration>("Twitter4QML", major, minor, "Configuration");
    qmlRegisterType<Languages>("Twitter4QML", major, minor, "LanguagesModel");

    qmlRegisterType<Privacy>("Twitter4QML", major, minor, "Privacy");
    qmlRegisterType<Tos>("Twitter4QML", major, minor, "Tos");

    qmlRegisterType<ShowRelatedResults>("Twitter4QML", major, minor, "RelatedResultsModel");
    qmlRegisterType<ActivitySummary>("Twitter4QML", major, minor, "ActivitySummary");
}

QNetworkAccessManager *Twitter4QML::networkAccessManager() const
{
    return OAuthManager::instance().networkAccessManager();
}

void Twitter4QML::setNetworkAccessManager(QNetworkAccessManager *networkAccessManager)
{
    OAuthManager::instance().setNetworkAccessManager(networkAccessManager);
}
