//
//  MotivationView.swift
//  X-LifeEnhance
//
//  Created by Simon Bakhanets on 27.01.2026.
//

import SwiftUI

struct MotivationView: View {
    @EnvironmentObject var viewModel: MotivationViewModel
    @State private var selectedArticle: Article?
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.appBackground
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Quote of the day
                        if let quote = viewModel.quoteOfTheDay {
                            QuoteCard(quote: quote)
                        }
                        
                        // Articles section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Inspiring Articles")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding(.horizontal)
                            
                            ForEach(viewModel.articles) { article in
                                ArticleCardView(article: article)
                                    .onTapGesture {
                                        selectedArticle = article
                                    }
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Daily Inspiration")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        viewModel.refreshContent()
                    }) {
                        Image(systemName: "arrow.clockwise")
                            .foregroundColor(.appPrimary)
                    }
                }
            }
            .sheet(item: $selectedArticle) { article in
                ArticleDetailView(article: article)
            }
        }
    }
}

struct QuoteCard: View {
    let quote: Quote
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "quote.bubble.fill")
                .font(.system(size: 40))
                .foregroundColor(.appPrimary)
            
            Text(quote.text)
                .font(.title3)
                .fontWeight(.medium)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
            
            Text("— \(quote.author)")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.7))
                .italic()
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color.appPrimary.opacity(0.3), Color.appSecondary.opacity(0.3)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [.appPrimary, .appSecondary]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 2
                )
        )
    }
}

struct ArticleCardView: View {
    let article: Article
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(article.title)
                        .font(.headline)
                        .foregroundColor(.white)
                        .lineLimit(2)
                    
                    Text(article.category)
                        .font(.caption)
                        .foregroundColor(.appPrimary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.appPrimary.opacity(0.2))
                        .cornerRadius(4)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.white.opacity(0.4))
            }
            
            HStack {
                Label("\(article.readTime) min read", systemImage: "clock.fill")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.6))
                
                Spacer()
                
                Text(formatDate(article.publishDate))
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.6))
            }
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(16)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

struct ArticleDetailView: View {
    @Environment(\.presentationMode) var presentationMode
    let article: Article
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.appBackground
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Header
                        VStack(alignment: .leading, spacing: 12) {
                            Text(article.category)
                                .font(.subheadline)
                                .foregroundColor(.appPrimary)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.appPrimary.opacity(0.2))
                                .cornerRadius(8)
                            
                            Text(article.title)
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            HStack {
                                Label("\(article.readTime) min read", systemImage: "clock.fill")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.6))
                                
                                Spacer()
                                
                                Text(formatDate(article.publishDate))
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.6))
                            }
                        }
                        .padding()
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(16)
                        
                        // Content
                        Text(article.content)
                            .font(.body)
                            .foregroundColor(.white.opacity(0.9))
                            .lineSpacing(8)
                            .padding()
                    }
                    .padding()
                }
            }
            .navigationTitle("Article")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(.appPrimary)
                }
            }
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter.string(from: date)
    }
}
