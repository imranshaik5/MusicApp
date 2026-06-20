import SwiftUI

struct ContentView: View {
    @State private var libraryVM = LibraryViewModel()
    @State private var playerVM = PlayerViewModel()
    @State private var searchVM = SearchViewModel()
    @State private var selectedSidebarItem: SidebarItem = .home
    @State private var showNowPlaying = false
    @State private var isSignedIn = false

    enum SidebarItem: Hashable {
        case search
        case home
        case new
        case radio
        case library(LibraryViewModel.LibraryCategory)
    }

    var body: some View {
        HSplitView {
            sidebar
                .frame(minWidth: 200, idealWidth: 250, maxWidth: 300)

            VStack(spacing: 0) {
                mainContent
                nowPlayingBar
            }
            .frame(minWidth: 600)
        }
        .sheet(isPresented: $showNowPlaying) {
            NowPlayingView()
                .environment(playerVM)
        }
        .environment(libraryVM)
        .environment(playerVM)
        .environment(searchVM)
        .task {
            await libraryVM.loadLibrary()
        }
    }

    @ViewBuilder
    private var sidebar: some View {
        VStack(spacing: 0) {
            List(selection: $selectedSidebarItem) {
                Section("") {
                    Label("Search", systemImage: "magnifyingglass")
                        .tag(SidebarItem.search)
                    Label("Home", systemImage: "house")
                        .tag(SidebarItem.home)
                    Label("New", systemImage: "sparkles")
                        .tag(SidebarItem.new)
                    Label("Radio", systemImage: "dot.radiowaves.left.and.right")
                        .tag(SidebarItem.radio)
                }

                Section("Library") {
                    Label("Recently Added", systemImage: "clock")
                        .tag(SidebarItem.library(.recentlyAdded))
                    Label("Artists", systemImage: "person.crop.square")
                        .tag(SidebarItem.library(.artists))
                    Label("Albums", systemImage: "square.stack")
                        .tag(SidebarItem.library(.albums))
                    Label("Songs", systemImage: "music.note")
                        .tag(SidebarItem.library(.songs))
                }

                Section("Playlists") {
                    ForEach(Array(libraryVM.playlists.enumerated()), id: \.element.id) { _, playlist in
                        Label(playlist.name, systemImage: "music.note")
                    }
                }
            }
            .listStyle(.sidebar)
            .onChange(of: selectedSidebarItem) { _, newItem in
                if case .library(let category) = newItem {
                    libraryVM.selectedCategory = category
                    if category == .recentlyAdded {
                        libraryVM.sortOrder = .recentlyAdded
                    } else {
                        libraryVM.sortOrder = .title
                    }
                }
            }

            Divider()

            profileSection
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
        }
        .frame(minWidth: 200)
    }

    private var profileSection: some View {
        HStack(spacing: 10) {
            Image(systemName: "person.circle.fill")
                .font(.title2)
                .foregroundStyle(.secondary)

            if isSignedIn {
                VStack(alignment: .leading, spacing: 1) {
                    Text("User Name")
                        .font(.callout)
                        .lineLimit(1)
                    Text("View Profile")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
            } else {
                Text("Sign In")
                    .font(.callout)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            if !isSignedIn {
                isSignedIn = true
            }
        }
    }

    @ViewBuilder
    private var mainContent: some View {
        if case .search = selectedSidebarItem {
            SearchView()
        } else if case .home = selectedSidebarItem {
            HomeView()
        } else if case .new = selectedSidebarItem {
            BrowseView()
        } else if case .radio = selectedSidebarItem {
            RadioView()
        } else if case .library = selectedSidebarItem {
            LibraryView()
        }
    }

    private var nowPlayingBar: some View {
        NowPlayingBar(showNowPlaying: $showNowPlaying)
    }
}
