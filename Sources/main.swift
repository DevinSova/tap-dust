import Foundation

struct DustloopResponse: Decodable {
  let cargoquery: [TitleData]
}

struct TitleData: Decodable {
  let title: MoveData
}

struct MoveData: Decodable {
  let damage: String?
  let input: String?
  let name: String?
}

var dustloopRequest = URLComponents()
dustloopRequest.scheme = "https"
dustloopRequest.host = "www.dustloop.com"
dustloopRequest.path = "/wiki/api.php"

var queryParameters = [URLQueryItem]()
queryParameters.append(URLQueryItem(name: "action", value: "cargoquery"))
queryParameters.append(URLQueryItem(name: "format", value: "json"))
queryParameters.append(URLQueryItem(name: "tables", value: "MoveData_GGST"))
queryParameters.append(URLQueryItem(name: "fields", value: "input, damage, name"))
queryParameters.append(URLQueryItem(name: "where", value: "chara=\"Sol Badguy\""))
queryParameters.append(URLQueryItem(name: "utf8", value: "1"))

dustloopRequest.queryItems = queryParameters

guard let url = dustloopRequest.url else {
  print("Failed to create URL Request String.")
  exit(1)
}

print(url.absoluteString)

let session = URLSession.shared
let semaphore = DispatchSemaphore(value: 0)

let task = session.dataTask(with: url) { (data: Data?, response, error) in
  if let error = error {
    print("Error: \(error.localizedDescription)")
    return
  }

  // Check if we have recieved any data
  guard let data = data else {
    print("No data recieved from dustloop API")
    return
  }

  // Parse the JSON data
  do {
    let jsonString = try JSONDecoder().decode(DustloopResponse.self, from: data)
    print(jsonString)

  } catch {
    print("Error parsing JSON: \(error)")
  }

  semaphore.signal()
}

task.resume()
semaphore.wait()
