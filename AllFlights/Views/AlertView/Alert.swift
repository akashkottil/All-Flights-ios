import SwiftUI

struct Alert : View {
    var body: some View {
        NavigationView{
            ZStack{
                GradientColor.BlueWhite
                    .ignoresSafeArea()
                
                VStack{
                    HStack{
                        Image("FlightAlert")
                        Spacer()
                        HStack{
                            Image("passengeralert")
                            Text("1")
                        }
                    }
                    Spacer()
                }
            }
        }
    }
}

#Preview {
    Alert()
}
