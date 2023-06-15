//
//  ApiManager.swift
//  Optimum
//
//  Created by MacBook Pro on 7/24/19.
//  Copyright © 2019 WaysGroup. All rights reserved.
//

import Foundation
import Alamofire
import PKHUD
import MOLH

class ApiManager {
    
    static let shared = ApiManager()
    private init() {}
    private let url = "https://devbeauty.vrouapp.com/api"
    let AuthHeaders = [
        "Authorization": "Bearer \(User.shared.TakeToken())",
        "Accept": "application/json"
    ]
    
    //    let AcceptHeader = [
    //        "Accept": "application/json",
    //        "locale":  UserDefaults.standard.string(forKey: "Language") ?? "en"
    //    ]
    //
    //    let AcceptLocalHeaders = [
    //        "Accept": "application/json",
    //        "locale": UserDefaults.standard.string(forKey: "Language") ?? "en"
    //    ]
    //
    //    let AuthHeadersLocal = [
    //        "Authorization": "Bearer \(User.shared.TakeToken())",
    //        "Accept": "application/json",
    //        "locale": UserDefaults.standard.string(forKey: "Language") ?? "en"
    //    ]
    
    let EncodingType = JSONEncoding.default
    let QueryEncodingType = URLEncoding.default
    
    enum Apis {
        
        case  Login, ResetPassword, CountriesList, CitiesList, Register, YourWorld, Discover, BeautyWorld, SalonAbout, SalonOffers, ServicesCategories, SalonServices, ProductCategories, SalonProducts, SalonBranches, RecommendSalons, FollowSalon , unfollowSalon, TermsConditions, Sections, CenterList, OfferCategories, OfferList, OfferDetails, ServiceDetials, InServicesCategories, ServicesList, OfferCategoryDetails, ProductCategoriesII, ProductList, ProductDetails, ServicesListHomeSalon, FreeAdsList, NearBranchesMAP, profile, AboutURLs, AddOfferProductToCart, AddServiceToCart, ServiceCartDetails, RemoveOfferProductFromCart, ContactUs, advertise, ChangePassword, Logout, LanguagesList, UpdateSettings, GetOfferPtoductCart, RemoveServiceFromCart, addSalonReview, SalonReviews, RemoveProductFromCart, CheckPromoCode, checkout, updateProfile , RefreshDeviceToken, MyReservations, Mypurchases, MyFavourites, AddToFavourite, RemoveFromFavourite, BeautyWorldAuth, DiscoverAuth, Search, salonsVideo, SocialLogin, NotificationsList, SetNotificationsSeen, ConfirmReservationReschedule, AlbumData, CommentsList, AddComment, DeleteComment, LikeComment, CreateCollection_addItem, DeleteColleciton, CollectionList, AddDeleteVisitSalon, UserSalonsReviews, uploadUserMedia, ShareItem, Like_Dislike, CreateEvent, AcceptRejectEvent, EventsList, EventDetails, AreasList, VisitedSalon, WeekOffers, WatchingList, FollowUnfollowUser, UserProfile, RequestsList, AcceptRejectRequest, getTutorials, HomeOffers, CheckEmailExist, getUserGallery,
        ReservationDetails, branchAvailableTime, AddMultiServiceToCart
        
        var description: String {
            // let url =    "https://vrouapp.com/api-v2"
            //    let url = "https://beauty-apps.com/api-v2"
            let url = "https://beauty.vrouapp.com/api-v3"
            // let url = "https://devbeauty.vrouapp.com/api-v3"
            
            switch self {
            case .Login:   return url + "/auth/login"
            case .ResetPassword:   return url + "/auth/password/reset"
            case .CountriesList:   return url + "/common/countries"
            case .CitiesList:   return url + "/common/cities?country_id="
            case .Register:   return url + "/auth/register"
            case .YourWorld:   return url + "/home/auth-tab-one"
            case .Discover:   return url + "/home/tab-two"
            case .BeautyWorld:   return url + "/home/tab-three?city_id="
            case .SalonAbout:   return url + "/salon/about?salon_id="
            case .SalonOffers:   return url + "/salon/offers?salon_id="
            case .ServicesCategories:   return url + "/salon/services-categories?salon_id="
            case .SalonServices:   return url + "/salon/services?"
            case .ProductCategories:   return url + "/salon/products-categories?salon_id="
            case .SalonProducts:   return url + "/salon/products?"
            case .SalonBranches:   return url + "/salon/branches?salon_id="
            case .RecommendSalons:   return url + "/categories/recommendation-salons?city_id="
            case .FollowSalon:   return url + "/user/follow"
            case .unfollowSalon:   return url + "/user/unfollow"
            case .TermsConditions:   return url + "/common/settings"
            case .Sections:   return url + "/categories/sections"
            case .CenterList:   return url + "/categories/list"
            case .OfferCategories:   return url + "/offers/offers-categories?type="
            case .OfferList:   return url + "/offers/offers-list?category_id="
            case .OfferDetails:   return url + "/offers/offer-details"
            case .ServiceDetials:   return url + "/services/service-details?"
            case .InServicesCategories:   return url + "/services/services-categories-salon?category_id="
            case .ServicesList:   return url + "/services/services-list?service_category_id="
            case .OfferCategoryDetails:   return url + "/offers/offer-category-details?offerCategory_id="
            case .ProductCategoriesII:   return url + "/stores/products-categories?category_id="
            case .ProductList:   return url + "/stores/products-list"
            case .ProductDetails:   return url + "/stores/products-details"
            case .ServicesListHomeSalon:   return url + "/services/services-categories-salon-home?home_status="
            case .FreeAdsList:   return url + "/ads/free?"
            case .NearBranchesMAP:   return url + "/salon/near-branches?"
            case .profile:   return url + "/user/profile"
            case .AboutURLs:   return url + "/common/about-urls"
            case .AddOfferProductToCart:   return url + "/order/offers-products/add-to-cart"
            case .AddServiceToCart:   return url + "/order/services/add-to-cart"
            case .ServiceCartDetails:   return url + "/order/services/get-cart-details"
            case .RemoveOfferProductFromCart:   return url + "/order/offers-products/remove-from-cart"
            case .ContactUs:   return url + "/common/contact-us"
            case .advertise:   return url + "/common/advertise"
            case .ChangePassword:   return url + "/auth/password/change-password"
            case .Logout:   return url + "/auth/logout"
            case .LanguagesList:   return url + "/common/languages"
            case .UpdateSettings:   return url + "/user/update-settings"
            case .GetOfferPtoductCart:   return url + "/order/offers-products/get-cart-details"
            case .RemoveServiceFromCart:   return url + "/order/services/remove-from-cart"
            case .addSalonReview:   return url + "/salon/add-salon-review"
            case .SalonReviews:   return url + "/salon/reviews?salon_id="
            case .RemoveProductFromCart:   return url + "/order/offers-products/remove-product-from-cart"
            case .CheckPromoCode:   return url + "/order/apply-promo-code"
            case .checkout:   return url + "/order/checkout"
            case .updateProfile:   return url + "/user/update-profile"
            case .RefreshDeviceToken:   return url + "/user/refresh-device-token"
            case .MyReservations:   return url + "/user/reservations?reservation_type="
            case .Mypurchases:   return url + "/user/purchases"
            case .MyFavourites:   return url + "/user/favorites?type="
            case .AddToFavourite:   return url + "/user/add-favourite"
            case .RemoveFromFavourite:   return url + "/user/remove-favourite"
            case .BeautyWorldAuth:   return url + "/home/auth-tab-three?city_id="
            case .DiscoverAuth:   return url + "/home/auth-tab-two?city_id="
            case .Search:   return url + "/common/search?"
            case .salonsVideo:   return url + "/common/salons-videos?city_id="
            case .SocialLogin:   return url + "/auth/social-login"
            case .NotificationsList:   return url + "/user/notifications/list?notifications_type="
            case .SetNotificationsSeen:   return url + "/user/notifications/seen"
            case .ConfirmReservationReschedule:   return url + "/order/services/update-schedule-reservation"
            case .AlbumData:   return url + "/salon/album-data?album_id="
            case .CommentsList:   return url + "/common/comments-list?commentable_type="
            case .AddComment:   return url + "/user/add-comment"
            case .DeleteComment:   return url + "/user/delete-comment?comment_id="
            case .LikeComment:   return url + "/user/like-comment"
            case .CreateCollection_addItem:   return url + "/user/create-collection-or-item-to-collection"
            case .DeleteColleciton:   return url + "/user/create-collection-or-item-to-collection"
            case .CollectionList:   return url + "/user/collections-list?type="
            case .AddDeleteVisitSalon:   return url + "/user/add-or-delete-visited-salon"
            case .UserSalonsReviews:   return url + "/user/salon-reviews-list"
            case .uploadUserMedia:   return url + "/user/upload-media"
            case .ShareItem:   return url + "/common/increment-share-count"
            case .Like_Dislike:   return url + "/user/like-or-dislike"
            case .CreateEvent:   return url + "/user/create-event"
            case .AcceptRejectEvent:   return url + "/user/accept-or-reject-offer-event"
            case .EventsList:   return url + "/user/events-list"
            case .EventDetails:   return url + "/user/event-details?event_id="
            case .AreasList:   return url + "/common/areas?city_id="
            case .VisitedSalon:   return url + "/user/visited-salons-list?page="
            case .WeekOffers:   return url + "/offers/week-offers?city_id="
            case .WatchingList:   return url + "/user/watching-list?watchable_id="
            case .FollowUnfollowUser:   return url + "/user/follow-and-unfollow-user"
            case .UserProfile:   return url + "/user/user-profile?user_id="
            case .RequestsList:   return url + "/user/following-requests-list"
            case .AcceptRejectRequest:   return url + "/user/accept-reject-following-requests"
            case .getTutorials : return  url + "/tutorials/list"
            case .HomeOffers : return  url + "/home/offers"
            case .CheckEmailExist : return  url + "/auth/check-mail-exist"
            case .getUserGallery: return url + "/user/gallery"
            case .ReservationDetails: return url + "/services/common-branches?"
            case .branchAvailableTime: return url + "/salon/branch-available-time?"
            case .AddMultiServiceToCart:  return url + "/order/services/add-multi-to-cart"
            }
        }
    }
    
    
    
    func ApiRequest(URL: URLConvertible ,  method: HTTPMethod ,  parameters:[String:Any] = ["":""] , encoding: ParameterEncoding = URLEncoding.default , Header: HTTPHeaders? = nil , ExtraParams:Any?... , view:UIView ,completion: @escaping (_ :Data?,_ error: String?) -> Void)
        
    {
        // HUD.show(.progress , onView: view)
        view.isUserInteractionEnabled = false
        Alamofire.request(URL,method: method, parameters: parameters, encoding: encoding, headers: Header).responseJSON { (response:DataResponse) in
            
            switch(response.result) {
            case .success(let value):
                print(response.value ?? "ERRor")
                print(response.result.error ?? "ERRor")
                print(response.response?.statusCode ?? "ERRor")
                print(response.response?.allHeaderFields["x-access-token"] ?? "ERRor")
                print(value)
                let temp = response.response?.statusCode ?? 400
                if temp >= 300 {
                    view.isUserInteractionEnabled = true
                    completion(response.data,"ERROR")
                    //  HUD.flash(.labeledError(title: "\(response.error?[0])", subtitle: <#T##String?#>))
                    do {
                        
                        if temp == 404 {
                            HUD.flash(.label("Page "), onView: view, delay: 3.0, completion: { (tmp) in
                                completion(response.data,"404")
                            })
                        }else if temp == 401 {
                            completion(response.data,"401")
                        }else if temp == 402 {
                            completion(response.data,"402")
                        } else {
                            let er = try JSONDecoder().decode(ErrorMsg.self, from: response.data!)
                            HUD.flash(.label("\(er.msg?[0] ?? "")") , onView: view , delay: 2 , completion: nil)
                            print(response.value ?? "ERRor")
                            print(response.result.error ?? "ERRor")
                            print(response.response?.statusCode ?? "ERRor")
                        }
                        
                    }catch {
                        HUD.flash(.label("Something went wrong Please try again later") , onView: view , delay: 2 , completion: nil)
                    }
                }else{
                    view.isUserInteractionEnabled = true
                    completion(response.data,nil)
                }
            case .failure(let error):
                view.isUserInteractionEnabled = true
                print(error.localizedDescription)
                //completion(nil,"Something went wrong Please try again later #101")
                completion(nil,"NoConnect")
                //   HUD.flash(.label("Something went wrong Please try again later") , onView: view , delay: 1.6 , completion: nil)
                break
            }
        }
    }
    
    
}


