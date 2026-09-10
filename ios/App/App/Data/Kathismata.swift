import Foundation

struct Kathisma {
    let number: Int
    let range: String
    let psalms: [Int]
}

// The 20 kathismata — traditional Orthodox liturgical division of the Psalter
let kathismata: [Kathisma] = [
    Kathisma(number: 1, range: "1–8", psalms: [1, 2, 3, 4, 5, 6, 7, 8]),
    Kathisma(number: 2, range: "9–16", psalms: [9, 10, 11, 12, 13, 14, 15, 16]),
    Kathisma(number: 3, range: "17–23", psalms: [17, 18, 19, 20, 21, 22, 23]),
    Kathisma(number: 4, range: "24–31", psalms: [24, 25, 26, 27, 28, 29, 30, 31]),
    Kathisma(number: 5, range: "32–36", psalms: [32, 33, 34, 35, 36]),
    Kathisma(number: 6, range: "37–45", psalms: [37, 38, 39, 40, 41, 42, 43, 44, 45]),
    Kathisma(number: 7, range: "46–54", psalms: [46, 47, 48, 49, 50, 51, 52, 53, 54]),
    Kathisma(number: 8, range: "55–63", psalms: [55, 56, 57, 58, 59, 60, 61, 62, 63]),
    Kathisma(number: 9, range: "64–69", psalms: [64, 65, 66, 67, 68, 69]),
    Kathisma(number: 10, range: "70–76", psalms: [70, 71, 72, 73, 74, 75, 76]),
    Kathisma(number: 11, range: "77–84", psalms: [77, 78, 79, 80, 81, 82, 83, 84]),
    Kathisma(number: 12, range: "85–90", psalms: [85, 86, 87, 88, 89, 90]),
    Kathisma(number: 13, range: "91–100", psalms: [91, 92, 93, 94, 95, 96, 97, 98, 99, 100]),
    Kathisma(number: 14, range: "101–104", psalms: [101, 102, 103, 104]),
    Kathisma(number: 15, range: "105–108", psalms: [105, 106, 107, 108]),
    Kathisma(number: 16, range: "109–117", psalms: [109, 110, 111, 112, 113, 114, 115, 116, 117]),
    Kathisma(number: 17, range: "118", psalms: [118]),
    Kathisma(number: 18, range: "119–133", psalms: [119, 120, 121, 122, 123, 124, 125, 126, 127, 128, 129, 130, 131, 132, 133]),
    Kathisma(number: 19, range: "134–142", psalms: [134, 135, 136, 137, 138, 139, 140, 141, 142]),
    Kathisma(number: 20, range: "143–150", psalms: [143, 144, 145, 146, 147, 148, 149, 150]),
]
