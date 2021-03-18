//
//  Models.swift
//  Concertmaster
//
//  Created by Adriano Brandao on 01/02/20.
//  Copyright © 2020 Open Opus. All rights reserved.
//

import SwiftUI

struct Composers: Codable {
    var composers: [Composer]?
}

struct Composer: Codable, Identifiable {
    let id: String
    var name: String
    var complete_name: String
    var birth: String?
    var death: String?
    var epoch: String
    var portrait: URL?
}

struct Genres: Codable {
    var genres: [String]?
}

struct Works: Codable {
    var works: [Work]?
}

struct Work: Codable, Identifiable {
    let id: String
    var title: String
    var subtitle: String?
    var genre: String
    var recommended: String?
    var popular: String?
    var composer: Composer?
}

struct Omnisearch: Codable {
    var recordings: [Recording]?
    var composers: [Composer]?
    var works: [Work]?
    var next: Int?
}

struct RecentSearch: Codable {
    var recording: Recording?
    var composer: Composer?
    var work: Work?
}

extension RecentSearch: Identifiable, Equatable {
    var id: String { return "albumid_\(recording?.spotify_albumid ?? "0")_work_\(work?.id ?? "0")_composer_\(composer?.id ?? "0")" }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func ==(lhs: RecentSearch, rhs: RecentSearch) -> Bool {
        return lhs.id == rhs.id
    }
}

struct OmniResults: Codable {
    var composer: Composer
    var work: Work?
    var next: Int?
}

extension OmniResults: Identifiable {
    var id: String { return "work_\(work?.id ?? "0")_composer_\(composer.id)" }
}

struct PlaylistRecordings: Codable {
    var recordings: [Recording]?
}

struct FullRecording: Codable {
    var work: Work
    var recording: Recording
}

extension FullRecording: Identifiable, Equatable {
    var id: String { return "\(recording.tracks!.first!.spotify_trackid)-\(work.id)-\(recording.spotify_albumid)-\(recording.set)" }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func ==(lhs: FullRecording, rhs: FullRecording) -> Bool {
        return lhs.id == rhs.id
    }
}

struct Recordings: Codable {
    var recordings: [Recording]?
    var next: String?
}

struct Track: Codable {
    var cd: Int
    var index: Int
    var length: Int
    var title: String
    var spotify_trackid: String
    var preview: URL?
    var starting_point: Int
    
    var readableLength: String {
        get { return convertSeconds(seconds: length) }
    }
}

extension Track: Identifiable {
    var id: String { return spotify_trackid }
}

struct CurrentTrack: Codable {
    var track_index: Int
    var zero_index: Int
    var playing: Bool
    var loading: Bool
    var starting_point: Int
    var track_position: Int
    var track_length: Int
    var full_position: Int
    var full_length: Int
    var preview: Bool
    var id: String
    
    var track_progress: CGFloat {
        get { return CGFloat(Double (track_position)/(preview ? 30 : Double (track_length))) }
    }
    
    var full_progress: CGFloat {
        get { return CGFloat(Double (full_position)/Double (full_length)) }
    }
    
    var readable_track_position: String {
        get { return convertSeconds(seconds: track_position) }
    }
    
    var readable_full_position: String {
        get { return convertSeconds(seconds: full_position) }
    }
}

struct Recording: Codable {
    var cover: URL?
    var spotify_albumid: String
    var singletrack: String?
    var compilation: String?
    var observation: String?
    var performers: [Performer]
    var set: String
    var historic: String?
    var verified: String
    var label: String?
    var length: Int?
    var tracks: [Track]?
    var spotify_tracks: [String]?
    var previews: [String?]?
    var work: Work?
    var position: Int?
    var recording_id: String?
    
    var isVerified: Bool {
        get { return verified == "true" }
        set { verified = newValue ? "true" : "false" }
    }
    
    var isCompilation: Bool {
        get { return compilation == "true" }
        set { compilation = newValue ? "true" : "false" }
    }
    
    var readableLength: String {
        get { return convertSeconds(seconds: length ?? 0) }
    }
    
    var jsonPerformers: String {
        get {
            do {
                let jsonData = try JSONEncoder().encode(performers)
                return String(data: jsonData, encoding: .utf8)!
            } catch {
                return ""
            }
        }
    }
    
    var jsonTracks: String {
        get {
            do {
                let jsonData = try JSONEncoder().encode(spotify_tracks)
                return String(data: jsonData, encoding: .utf8)!
            } catch {
                return ""
            }
        }
    }
    
    var previewUrls: [URL] {
        get {
            var previewurls = [URL]()
            do {
                if let previews = previews {
                    for track in previews {
                        if let track = track {
                            if let trackurl = URL(string: track) {
                                previewurls.append(trackurl)
                            }
                        }
                    }
                }
            }
            
            return previewurls
        }
    }
}

extension Recording: Identifiable, Equatable {
    var id: String {
        if let rid = recording_id {
            return rid
        }
        else {
            return "\(work?.id ?? "0")-\(spotify_albumid)-\(set)"
        }
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func ==(lhs: Recording, rhs: Recording) -> Bool {
        return lhs.id == rhs.id
    }
}

struct Performer: Codable {
    var name: String
    var role: String?
    
    var readableRole: String {
        get {
            var ret = ""
            
            if let rol = role {
                if (rol != "" && !AppConstants.groupList.contains(rol)) {
                    ret = ", \(rol)"
                }
            }
            
            return ret
        }
    }
}

struct Album: Codable {
    var cover: URL?
    var spotify_albumid: String
    var title: String
    var label: String
    var length: Int?
    var spotify_tracks: [String]?
    var previews: [URL]?
    var year: String
    
    var readableLength: String {
        get { return convertSeconds(seconds: length ?? 0) }
    }
}

struct FullAlbum: Codable {
    var album: Album
    var recordings: [FullRecording]
}

struct Recommendations: Codable {
    var data: [Recommendation]
}

struct Recommendation: Codable, Identifiable {
    var id: String
    var type: String
}

struct Login: Codable {
    var user: User
    var composerworks: [String]?
    var favoriterecordings: [String]?
    var works: [String]?
    var favorite: [String]?
    var forbidden: [String]?
    var playlists: [Playlist]?
}

struct User: Codable, Identifiable {
    var id: String
    var auth: String?
    var heavyuser: Int?
    var country: String?
    var product: String?
}

struct Token: Codable {
    var token: String
}

struct Playlist: Codable, Identifiable {
    var id: String
    var name: String
    var owner: String
    var summary: PlaylistSummary
}

struct PlaylistSummary: Codable {
    var composers: PlaylistComposers
    var works: PlaylistWorks
}

struct PlaylistComposers: Codable {
    var portraits: [URL]
    var names: [String]
    var rows: Int
    
    var nameList: String {
        get {
            return (names.prefix(4).map{String($0)}).joined(separator: ", ")
        }
    }
}

struct PlaylistWorks: Codable {
    var rows: Int
}

struct PlayerState: Codable {
    var isConnected: Bool
    var isPlaying: Bool
    var trackId: String
    var position: Int
}

struct AddComposer: Codable {
    var list: [String]
}

struct AddWork: Codable {
    var list: [String]
    var composerworks: [String]
}

struct AddRecordings: Codable {
    var favoriterecordings: [String]
}

struct ShortRecordingDetail: Codable {
    var recording: ShortRecording
}

struct ShortRecording: Codable {
    var id: String
    var work_id: String?
    var spotify_albumid: String?
    var set: String?
}

struct PlaylistRecording: Codable {
    var list: [Playlist]
}

struct RadioStationPlaylist: Codable {
    var id: String
    var name: String
    var cover: URL
}

struct RadioStationPlaylists: Codable {
    var playlists: [RadioStationPlaylist]
}

struct Supporters: Codable {
    var patrons: [String]
}

struct TrackQueue: Codable {
    var tracks: [TrackQueued]
}

struct TrackQueued: Codable {
    var spotify_trackid: String
    var recording_id: String
}

struct RecordingQueue: Codable {
    var recordings: [Recording]
}

struct Devices: Codable {
    var devices: [Device]
}

struct Device: Codable {
    var id: String
    var is_active: Bool
    var name: String
    var type: String
}

struct SpotifyPlayer: Codable {
    var device: Device?
    var item: SpotifyItem?
}

struct SpotifyItem: Codable {
    var uri: String
}
