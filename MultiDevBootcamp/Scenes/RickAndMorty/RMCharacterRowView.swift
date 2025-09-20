//
//  RMCharacterRowView.swift
//  MultiDevBootcamp
//
//  Created by dogukaan on 20.09.2025.
//

import SwiftUI

struct RMCharacterRowView: View {
    let character: RMCharacter
    @Binding var isFavorite: Bool
    @Binding var isWatchlisted: Bool

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            AsyncImage(url: URL(string: character.image)) { phase in
                switch phase {
                case .success(let image):
                    image.resizable()
                case .failure(_):
                    Image(systemName: "exclamationmark.triangle").resizable()
                case .empty:
                    Image(systemName: "photo").resizable()
                @unknown default:
                    Image(systemName: "photo").resizable()
                }
            }
            .scaledToFill()
            .frame(width: 48, height: 48)
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

            VStack(alignment: .leading, spacing: 6) {
                // Name
                Text(character.name)
                    .font(.headline)
                    .lineLimit(1)

                // Species • Gender
                Text("\(character.species)\(character.type.isEmpty ? "" : " (\(character.type))") • \(character.gender)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)

                // Status pill + origin/last seen
                VStack(alignment: .leading, spacing: 8) {
                    StatusPill(status: character.status)
                    Text("Origin: \(character.origin.name)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                    Text("· Last seen: \(character.location.name)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }

            Spacer(minLength: 8)

            VStack(alignment: .trailing, spacing: 8) {
                Button {
                    isFavorite.toggle()
                } label: {
                    Image(systemName: isFavorite ? "star.fill" : "star")
                        .foregroundStyle(isFavorite ? .yellow : .gray)
                }
                .buttonStyle(.plain)

                Button {
                    isWatchlisted.toggle()
                } label: {
                    Image(systemName: "bookmark")
                        .foregroundStyle(isWatchlisted ? .blue : .gray)
                }
                .buttonStyle(.plain)
            }
        }
        .contentShape(Rectangle())
    }
}

// MARK: - Status Pill
private struct StatusPill: View {
    let status: String

    var color: Color {
        switch status.lowercased() {
        case "alive": return .green
        case "dead":  return .red
        default:      return .gray
        }
    }

    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            Text(status)
                .font(.caption).bold()
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color(.systemGray6))
        .clipShape(Capsule())
    }
}

// MARK: - Preview
#Preview {
    RMCharacterRowView(
        character: .placeholder,
        isFavorite: .constant(true),
        isWatchlisted: .constant(false)
    )
    .padding()
}

// MARK: - Placeholder
extension RMCharacter {
    static let placeholder = RMCharacter(
        id: 1,
        name: "Rick Sanchez",
        status: "Alive",
        species: "Human",
        type: "",
        gender: "Male",
        origin: .init(name: "Earth (C-137)", url: "https://rickandmortyapi.com/api/location/1"),
        location: .init(name: "Citadel of Ricks", url: "https://rickandmortyapi.com/api/location/3"),
        image: "https://rickandmortyapi.com/api/character/avatar/1.jpeg",
        episode: [],
        url: "https://rickandmortyapi.com/api/character/1",
        created: "2017-11-04T18:48:46.250Z"
    )
}
