//
//  ContentView.swift
//  W_App
//
//  Created by Sumit Makasana on 17/01/25.
//

import SwiftUI

struct ContentView: View {
    @State private var cityName: String = ""
    @State private var weatherData: String = "Search for a city's weather"
    @State private var isLoading: Bool = false
    @State private var isDarkMode: Bool = false

    var body: some View {
        ZStack {
            isDarkMode ? Color.black.edgesIgnoringSafeArea(.all) : Color.white.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                HStack {
                    Text("Dark Mode")
                        .foregroundColor(isDarkMode ? .white : .black)
                        .font(.headline)
                    
                    Spacer()
                    
                    Toggle(isOn: $isDarkMode) {
                        EmptyView()
                    }
                    .toggleStyle(SwitchToggleStyle(tint: .blue))
                }
                .padding(.horizontal)
                
                HStack {
                    TextField("Enter city name", text: $cityName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                        .background(Color.clear)
                        .foregroundColor(isDarkMode ? .black : .black)
                        .cornerRadius(10)
                    
                    Button(action: fetchWeather) {
                        Text("Search")
                            .padding(.horizontal)
                            .padding(.vertical, 8)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }
                
                Text(isLoading ? "Loading..." : weatherData)
                    .padding()
                    .multilineTextAlignment(.center)
                    .font(.headline)
                    .foregroundColor(isDarkMode ? .white : .gray)
                    .background(isDarkMode ? Color.gray.opacity(0.2) : Color.gray.opacity(0.1))
                    .cornerRadius(10)
            }
            .padding()
        }
        .animation(.easeInOut, value: isDarkMode)
    }
    
    func fetchWeather() {
        
        
        print("HIIIII")
        
        guard !cityName.isEmpty else {
            weatherData = "Please enter a city name"
            return
        }
        
        isLoading = true
        let apiKey = "f19e6f8613654cf0898110325251701"
        let city = cityName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "https://api.weatherapi.com/v1/current.json?key=\(apiKey)&q=\(city)"
        
        guard let url = URL(string: urlString) else {
            weatherData = "Invalid URL"
            isLoading = false
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                isLoading = false
                
                if let error = error {
                    weatherData = "Error: \(error.localizedDescription)"
                    return
                }
                
                guard let data = data else {
                    weatherData = "No data received"
                    return
                }
                
                do {
                    let decodedData = try JSONDecoder().decode(WeatherResponse.self, from: data)
                    weatherData = """
                    City: \(decodedData.location.name)
                    Temperature: \(decodedData.current.temp_c)°C
                    Condition: \(decodedData.current.condition.text)
                    """
                } catch {
                    weatherData = "Failed to decode response"
                }
            }
        }.resume()
    }
}

struct WeatherResponse: Codable {
    let location: Location
    let current: Current
}

struct Location: Codable {
    let name: String
}

struct Current: Codable {
    let temp_c: Double
    let condition: Condition
}

struct Condition: Codable {
    let text: String
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
