import XCTest
@testable import RonCore

final class RonTests: XCTestCase {
    func testRonComments() {
        let frame = "*lww#test@time-orig! *~ 'comment'! *lww :int=1:str'2'";
        let ops = ["*lww#test@time-orig!",
                   "*~'comment'!",
                   "*lww:int=1",
                   "*lww:str'2'",];
        
        let f = Frame(str: frame)
        XCTAssertEqual(f.unzip.map { $0.toString() }, ops)
    }
    
    func testMainSection() throws {
        var a = Op(body: "#id=1")
        XCTAssertNotNil(a)
        XCTAssertEqual(a?.object.value, "id")
        XCTAssertEqual(a?.object.origin, "0")
        XCTAssertEqual(a?.object.sep, "$")
        XCTAssertEqual(a?.value(0), .int(1));
        XCTAssertEqual(a?.type.toString(), "0")
        XCTAssertEqual(a?.key, "*0#id")
        
        let frame = "*lww#test@time-orig!:int=1:str'2'"
        let ops = ["*lww#test@time-orig!",
                   "*lww#test@time-orig:int=1,",
                   "*lww#test@time-orig:str'2',",]
        let vals = [.removal,
                    Atom.int(1),
                    .string("2"),]
        let f = Frame(str: frame)
        var nf = Frame()
        var c = 0
        for ((var op, ops), val) in zip(zip(f, ops), vals) {
            XCTAssertEqual(op.toString(), ops);
            XCTAssertEqual(op.value(0), val);
            c == 0 ? nf.append(op) : nf.append(op, term: .comma);
            c += 1
        }
        XCTAssertEqual(nf.toString(), frame);
        
        let subs = ["$A": "1", "$B": "2"]
        let mapd = String(rawFrame: "@$A>0:$B>~") { uuid, _, _, _ in
            subs[uuid.toString()].map { .fromString($0) } ?? uuid
        }
        XCTAssertEqual(mapd, "@1>0:2>~")
        
        let big = "*lww#test@time-orig!:int=1@(1:str'2'@(3:ref>3"
        var from = Frame.Cursor(body: big)
        _ = from.nextOp()
        var till = from
        _ = till.nextOp()
        _ = till.nextOp()
        let crop = try from.slice(till: till)
        XCTAssertEqual(crop, "*lww#test@time-orig:int=1,@(1:str'2'")
        
        var arrit = Frame.Cursor(body: "*lww#array@2!@1:%=0@2:%1'1':1%0=1:%1=2")
        var ao = 0
        XCTAssertEqual(arrit.op?.isHeader, true);
        while let _ = arrit.nextOp() {
            XCTAssertEqual(arrit.op?.isHeader, false);
            ao += 1
        }
        XCTAssertEqual(ao, 4)
        
        XCTAssertEqual("'1'".ronToJs, [.string("1")])
        XCTAssertEqual(#"=1'x\"y\"z'^3.1>ref>true>false>0"#.ronToJs,
                       [.int(1),
                        .string(#"x"y"z"#),
                        .double(3.1),
                        .uuid(.fromString("ref")),
                        .bool(true),
                        .bool(false),
                        .none,])
        XCTAssertEqual(String(jsValues: [.int(1),
                                         .string(#"x"y"z"#),
                                         .double(3.1),
                                         .uuid(.fromString("ref")),
                                         .bool(true),
                                         .bool(false),
                                         .none,]),
                       #"=1'x\"y\"z'^3.1>ref>true>false>0"#)
        
        XCTAssertEqual(String(jsValues: [.string("don't")]).ronToJs, [.string("don't")])
    }
    
    func testUuidRest() {
        let source = ["*set#test1@2:d!",
                      "*set#test1@2=2,",
                      "*set#test1@1=1,",]
        var frame = Frame()
        for op in source {
            frame.append(Op(body: op)!)
        }
        XCTAssertEqual(frame.toString(), "*set#test1@2:d!:0=2@1=1")
    }
    
    func testBatchSplitById1() {
        let frame =
            "*set#mice@1Y4C9GS001+1Y4C9!@>mouse$1Y4C9@(8c5d01(8c>mouse$1Y4C8c@[W7D01[W>mouse$1Y4C8W@[OJ001[>mouse$1Y4C8@(7J5v01(7J>mouse$1Y4C7J@[D5x01[D>mouse$1Y4C7D@[8O001[>mouse$1Y4C7@(6MAd01(6M>mouse$1Y4C6M@[CH001[>mouse$1Y4C6@(4gRD01(4g>mouse$1Y4C4g@[f1101[>mouse$1Y4C4@(2A0Q01(2>mouse$1Y4C2@(1S7b01(1>mouse$1Y4C1@1Y4BvT4x01+1Y4Bv>mouse$1Y4Bv@(tpAI01(tp>mouse$1Y4Btp@[EFP01[E>mouse$1Y4BtE@[2Bq01[>mouse$1Y4Bt@(svAs01(su>mouse$1Y4Bsu@[T3s01[>mouse$1Y4Bs@(koCv01(k>mouse$1Y4Bk@(Xj3g01(X>mouse$1Y4BX@(Vt8q01(Vs>mouse$1Y4BVs@[AA101[>mouse$1Y4BV@(UFEC01(U>mouse$1Y4BU@(TR6301(T>mouse$1Y4BT@(SkCP01(Sk>mouse$1Y4BSk@[dCI01[d>mouse$1Y4BSd@[W0x01[V>mouse$1Y4BSV@[PB501[P>mouse$1Y4BSP@[9G001[>mouse$1Y4BS@(Rp8r01(R>mouse$1Y4BR@(PfDI01(P>mouse$1Y4BP@(Op7S01(Oo>mouse$1Y4BOo@[Y7v01[X>mouse$1Y4BOX@[T4F01[S>mouse$1Y4BOS@(Nu3l01(Nt>mouse$1Y4BNt@[r2i01[q>mouse$1Y4BNq@[S7O01[>mouse$1Y4BN@(Mg3101(Mf>mouse$1Y4BMf@[WFp01[W>mouse$1Y4BMW@[4D101[>mouse$1Y4BM@(Jp1a01(Jo>mouse$1Y4BJo@[B0401[9>mouse$1Y4BJ9@[73T01[6>mouse$1Y4BJ6@(Ir8701(Iq>mouse$1Y4BIq@[46s01[>mouse$1Y4BI@(HqEK01(Hq>mouse$1Y4BHq@[S0801[Q>mouse$1Y4BHQ@[41601[3>mouse$1Y4BH3@(GdFZ01(Gd>mouse$1Y4BGd@[7B701[>mouse$1Y4BG@1Y44Ha0o01+1Y44H>mouse$1Y44H@(EK4V01(EJ>mouse$1Y44EJ@[G9j01[G>mouse$1Y44EG@[D3G01[C>mouse$1Y44EC@[58d01[>mouse$1Y44E@(CeCS01(C>mouse$1Y44C*lww#mouse$1Y4C8c@1Y4C9hAK01+1Y4C8c!@[M9_01:symbol'❀'@[hAK01:x=599:y=177*lww#mouse$1Y4C8W@1Y4C8a3h01+1Y4C8W!:symbol'❀'@{2M01:x=180:y=91*lww#mouse$1Y4C8@1Y4C8U5L01+1Y4C8!@[P0g01:symbol'✟'@[U5L01:x=471:y=103*lww#mouse$1Y4C7J@1Y4C7mA~01+1Y4C7J!:symbol'✘'@{7_01:x=248:y=163*lww#mouse$1Y4C7D@1Y4C7H0g01+1Y4C7D!:symbol'✟'@[GE801:x=333:y=163*lww#mouse$1Y4C7@1Y4C7B8h01+1Y4C7!@[92u01:symbol'✔'@[B8h01:x=170:y=67*lww#mouse$1Y4C6M@1Y4C763i01+1Y4C6M!@[53U01:symbol'❄'@[63i01:x=300:y=146*lww#mouse$1Y4C6@1Y4C6JCn01+1Y4C6!:symbol'✵'@{Ap01:x=440:y=172*lww#mouse$1Y4C4g@1Y4C69AG01+1Y4C4g!@(5t4e01:symbol'✫'@(69AG01:x=298:y=124#mouse$1Y4C4!*lww#mouse$1Y4C2@1Y4C2A1g01+1Y4C2!@{0R01:symbol'✙'@{1g01:x=288:y=162*lww#mouse$1Y4C1@1Y4C1S7b02+1Y4C1!:symbol'❊'*lww#mouse$1Y4Bv@1Y4BvT4y01+1Y4Bv!:symbol'✓'*lww#mouse$1Y4Btp@1Y4Buk8S01+1Y4Btp!:symbol'❄'@{5p01:x=332:y=85*lww#mouse$1Y4BtE@1Y4Bte7I01+1Y4BtE!:symbol'✝'@{5w01:x=733:y=99*lww#mouse$1Y4Bt!@1Y4BtC3L01+1Y4Bt:symbol'✪'@{8n01:x=333:y=65*lww#mouse$1Y4Bsu!@1Y4BsvAs02+1Y4Bsu:symbol'✝'*lww#mouse$1Y4Bs!@1Y4Bs_Ak01+1Y4Bs:symbol'✞'@{9101:x=258:y=59*lww#mouse$1Y4Bk!@1Y4BkoCw01+1Y4Bk:symbol'✞'@(lv2S01:x=290:y=114*lww#mouse$1Y4BX!@1Y4BXj3h01+1Y4BX:symbol'✿'*lww#mouse$1Y4BVs!@1Y4BVt8q02+1Y4BVs:symbol'✙'*lww#mouse$1Y4BV!@1Y4BVAA102+1Y4BV:symbol'✑'@[QDL01:x=221:y=92*lww#mouse$1Y4BU!@1Y4BUFEC02+1Y4BU:symbol'✻'@(V54Q01:x=337:y=82*lww#mouse$1Y4BT!@1Y4BTR6302+1Y4BT:symbol'✟'@(UDFO01:x=325:y=117*lww#mouse$1Y4BSk!@1Y4BTM1Z01+1Y4BSk:symbol'✻'@[O5Y01:x=333:y=6*lww#mouse$1Y4BSd!@1Y4BSdCI02+1Y4BSd:symbol'✺'@[h3S01:x=331:y=83*lww#mouse$1Y4BSV!@1Y4BSaFa01+1Y4BSV:symbol'✻'@{BR01:x=334:y=7*lww#mouse$1Y4BSP!@1Y4BSSF601+1Y4BSP:symbol'✳'@{D301:x=154:y=34*lww#mouse$1Y4BS!@1Y4BSN0s01+1Y4BS:symbol'✽'@[MDn01:x=352:y=68*lww#mouse$1Y4BR!@1Y4BRp8r02+1Y4BR:symbol'✽'@(S8:x=200:y=132*lww#mouse$1Y4BP@1Y4C9EB901+1Y4BP!:symbol'❊'@{Az01:x=119:y=85*lww#mouse$1Y4BOo!@1Y4BReDy01+1Y4BOo:symbol'❁'@[gDU01:x=107:y=103*lww#mouse$1Y4BOX!@1Y4BOb4d01+1Y4BOX:symbol'✢'@[k9F01:x=259:y=84*lww#mouse$1Y4BOS!@1Y4BOT4F02+1Y4BOS:symbol'✑'@[VC401:x=285:y=52*lww#mouse$1Y4BNt!@1Y4BNu3m01+1Y4BNt:symbol'✠'@[w9g01:x=324:y=112*lww#mouse$1Y4BNq!@1Y4BNr2i02+1Y4BNq:symbol'✪'*lww#mouse$1Y4BN!@1Y4BNbCc01+1Y4BN:symbol'✢'@[oDg01:x=319:y=129*lww#mouse$1Y4BMf!@1Y4BMg3201+1Y4BMf:symbol'✞'@[jEB01:x=261:y=72*lww#mouse$1Y4BMW!@1Y4BMWFp02+1Y4BMW:symbol'✶'@[aFQ01:x=278:y=102*lww#mouse$1Y4BM!@1Y4BM4D102+1Y4BM:symbol'❇'@[93m01:x=410:y=152*lww#mouse$1Y4BJo!@1Y4BJp1a02+1Y4BJo:symbol'✘'@(LQAN01:x=235:y=115*lww#mouse$1Y4BJ9!@1Y4BJB0501+1Y4BJ9:symbol'❅'@[PDs01:x=377:y=99*lww#mouse$1Y4BJ6!@1Y4BJ73U01+1Y4BJ6:symbol'✦'*lww#mouse$1Y4BIq!@1Y4BIr8801+1Y4BIq:symbol'❂'*lww#mouse$1Y4BI!@1Y4BI46s02+1Y4BI:symbol'✥'@[8Al01:x=295:y=67*lww#mouse$1Y4BHq!@1Y4BHqEL01+1Y4BHq:symbol'✥'@(I06j01:x=466:y=79*lww#mouse$1Y4BHQ!@1Y4BHS0802+1Y4BHQ:symbol'❈'@[n9b01:x=252:y=101*lww#mouse$1Y4BH3!@1Y4BH41602+1Y4BH3:symbol'✝'@[B0O01:x=361:y=96*lww#mouse$1Y4BGd!@1Y4BGdF_01+1Y4BGd:symbol'✭'*lww#mouse$1Y4BG!@1Y4BG7B801+1Y4BG:symbol'✛'@[XFb01:x=406:y=168*lww#mouse$1Y44H!@1Y44Ha0p01+1Y44H:symbol'✬'*lww#mouse$1Y44EJ!@1Y44EK4W01+1Y44EJ:symbol'❄'*lww#mouse$1Y44EG!@1Y44EG9j02+1Y44EG:symbol'✣'*lww#mouse$1Y44EC!@1Y44ED3H01+1Y44EC:symbol'✭'*lww#mouse$1Y44E!@1Y44E58e01+1Y44E:symbol'❌'*lww#mouse$1Y44C!@1Y44CeCT01+1Y44C:symbol'✾'*lww#mouse$1Y4C9@1Y4C9ZEd01+1Y4C9!@[VF801:symbol'✟'@[ZEd01:x=195:y=157"
        
        let b = Batch.splitById(source: frame)
        XCTAssertEqual(b.count, 58)
        
        var arr = [String]()
        var ids = [String]()
        for f in b {
            arr.append(f.toString())
            ids.append(f.id.toString())
        }
        
        XCTAssertEqual(arr, [
            "*set#mice@1Y4C9GS001+1Y4C9!>mouse$1Y4C9@(8c5d01+(8c>mouse$1Y4C8c@[W7D01+[W>mouse$1Y4C8W@[OJ001+[>mouse$1Y4C8@(7J5v01+(7J>mouse$1Y4C7J@[D5x01+[D>mouse$1Y4C7D@[8O001+[>mouse$1Y4C7@(6MAd01+(6M>mouse$1Y4C6M@[CH001+[>mouse$1Y4C6@(4gRD01+(4g>mouse$1Y4C4g@[f1101+[>mouse$1Y4C4@(2A0Q01+(2>mouse$1Y4C2@(1S7b01+(1>mouse$1Y4C1@1Y4BvT4x01+1Y4Bv>mouse$1Y4Bv@(tpAI01+(tp>mouse$1Y4Btp@[EFP01+[E>mouse$1Y4BtE@[2Bq01+[>mouse$1Y4Bt@(svAs01+(su>mouse$1Y4Bsu@[T3s01+[>mouse$1Y4Bs@(koCv01+(k>mouse$1Y4Bk@(Xj3g01+(X>mouse$1Y4BX@(Vt8q01+(Vs>mouse$1Y4BVs@[AA101+[>mouse$1Y4BV@(UFEC01+(U>mouse$1Y4BU@(TR6301+(T>mouse$1Y4BT@(SkCP01+(Sk>mouse$1Y4BSk@[dCI01+[d>mouse$1Y4BSd@[W0x01+[V>mouse$1Y4BSV@[PB501+[P>mouse$1Y4BSP@[9G001+[>mouse$1Y4BS@(Rp8r01+(R>mouse$1Y4BR@(PfDI01+(P>mouse$1Y4BP@(Op7S01+(Oo>mouse$1Y4BOo@[Y7v01+[X>mouse$1Y4BOX@[T4F01+[S>mouse$1Y4BOS@(Nu3l01+(Nt>mouse$1Y4BNt@[r2i01+[q>mouse$1Y4BNq@[S7O01+[>mouse$1Y4BN@(Mg3101+(Mf>mouse$1Y4BMf@[WFp01+[W>mouse$1Y4BMW@[4D101+[>mouse$1Y4BM@(Jp1a01+(Jo>mouse$1Y4BJo@[B0401+[9>mouse$1Y4BJ9@[73T01+[6>mouse$1Y4BJ6@(Ir8701+(Iq>mouse$1Y4BIq@[46s01+[>mouse$1Y4BI@(HqEK01+(Hq>mouse$1Y4BHq@[S0801+[Q>mouse$1Y4BHQ@[41601+[3>mouse$1Y4BH3@(GdFZ01+(Gd>mouse$1Y4BGd@[7B701+[>mouse$1Y4BG@1Y44Ha0o01+1Y44H>mouse$1Y44H@(EK4V01+(EJ>mouse$1Y44EJ@[G9j01+[G>mouse$1Y44EG@[D3G01+[C>mouse$1Y44EC@[58d01+[>mouse$1Y44E@(CeCS01+(C>mouse$1Y44C",
            "*lww#mouse$1Y4C8c@1Y4C9hAK01+1Y4C8c!@[M9_01+:symbol'❀'@[hAK01+:x=599:y=177",
            "*lww#mouse$1Y4C8W@1Y4C8a3h01+1Y4C8W:y!:symbol'❀'@{2M01+:x=180:y=91",
            "*lww#mouse$1Y4C8@1Y4C8U5L01+1Y4C8:y!@[P0g01+:symbol'✟'@[U5L01+:x=471:y=103",
            "*lww#mouse$1Y4C7J@1Y4C7mA~01+1Y4C7J:y!:symbol'✘'@{7_01+:x=248:y=163",
            "*lww#mouse$1Y4C7D@1Y4C7H0g01+1Y4C7D:y!:symbol'✟'@[GE801+:x=333:y=163",
            "*lww#mouse$1Y4C7@1Y4C7B8h01+1Y4C7:y!@[92u01+:symbol'✔'@[B8h01+:x=170:y=67",
            "*lww#mouse$1Y4C6M@1Y4C763i01+1Y4C6M:y!@[53U01+:symbol'❄'@[63i01+:x=300:y=146",
            "*lww#mouse$1Y4C6@1Y4C6JCn01+1Y4C6:y!:symbol'✵'@{Ap01+:x=440:y=172",
            "*lww#mouse$1Y4C4g@1Y4C69AG01+1Y4C4g:y!@(5t4e01+:symbol'✫'@(69AG01+:x=298:y=124",
            "*lww#mouse$1Y4C4@1Y4C69AG01+1Y4C4g:y!",
            "*lww#mouse$1Y4C2@1Y4C2A1g01+1Y4C2:y!@{0R01+:symbol'✙'@{1g01+:x=288:y=162",
            "*lww#mouse$1Y4C1@1Y4C1S7b02+1Y4C1:y!:symbol'❊'",
            "*lww#mouse$1Y4Bv@1Y4BvT4y01+1Y4Bv:symbol!'✓'",
            "*lww#mouse$1Y4Btp@1Y4Buk8S01+1Y4Btp:symbol!'❄'@{5p01+:x=332:y=85",
            "*lww#mouse$1Y4BtE@1Y4Bte7I01+1Y4BtE:y!:symbol'✝'@{5w01+:x=733:y=99",
            "*lww#mouse$1Y4Bt@1Y4Bte5w01+1Y4BtE:y!@[C3L01+[:symbol'✪'@{8n01+:x=333:y=65",
            "*lww#mouse$1Y4Bsu@1Y4BtC8n01+1Y4Bt:y!@(svAs02+(su:symbol'✝'",
            "*lww#mouse$1Y4Bs@1Y4BsvAs02+1Y4Bsu:symbol!@[_Ak01+['✞'@{9101+:x=258:y=59",
            "*lww#mouse$1Y4Bk@1Y4Bs_9101+1Y4Bs:y!@(koCw01+(k:symbol'✞'@(lv2S01+:x=290:y=114",
            "*lww#mouse$1Y4BX@1Y4Blv2S01+1Y4Bk:y!@(Xj3h01+(X:symbol'✿'",
            "*lww#mouse$1Y4BVs@1Y4BXj3h01+1Y4BX:symbol!@(Vt8q02+(Vs'✙'",
            "*lww#mouse$1Y4BV@1Y4BVt8q02+1Y4BVs:symbol!@[AA102+['✑'@[QDL01+:x=221:y=92",
            "*lww#mouse$1Y4BU@1Y4BVQDL01+1Y4BV:y!@(UFEC02+(U:symbol'✻'@(V54Q01+:x=337:y=82",
            "*lww#mouse$1Y4BT@1Y4BV54Q01+1Y4BU:y!@(TR6302+(T:symbol'✟'@(UDFO01+:x=325:y=117",
            "*lww#mouse$1Y4BSk@1Y4BUDFO01+1Y4BT:y!@(TM1Z01+(Sk:symbol'✻'@[O5Y01+:x=333:y=6",
            "*lww#mouse$1Y4BSd@1Y4BTO5Y01+1Y4BSk:y!@(SdCI02+[d:symbol'✺'@[h3S01+:x=331:y=83",
            "*lww#mouse$1Y4BSV@1Y4BSh3S01+1Y4BSd:y!@[aFa01+[V:symbol'✻'@{BR01+:x=334:y=7",
            "*lww#mouse$1Y4BSP@1Y4BSaBR01+1Y4BSV:y!@[SF601+[P:symbol'✳'@{D301+:x=154:y=34",
            "*lww#mouse$1Y4BS@1Y4BSSD301+1Y4BSP:y!@[N0s01+[:symbol'✽'@[MDn01+:x=352:y=68",
            "*lww#mouse$1Y4BR@1Y4BSMDn01+1Y4BS:y!@(Rp8r02+(R:symbol'✽'@(S8+:x=200:y=132",
            "*lww#mouse$1Y4BP@1Y4C9EB901+1Y4BP:y!:symbol'❊'@{Az01+:x=119:y=85",
            "*lww#mouse$1Y4BOo@1Y4C9EAz01+1Y4BP:y!@1Y4BReDy01+(Oo:symbol'❁'@[gDU01+:x=107:y=103",
            "*lww#mouse$1Y4BOX@1Y4BRgDU01+1Y4BOo:y!@(Ob4d01+[X:symbol'✢'@[k9F01+:x=259:y=84",
            "*lww#mouse$1Y4BOS@1Y4BOk9F01+1Y4BOX:y!@[T4F02+[S:symbol'✑'@[VC401+:x=285:y=52",
            "*lww#mouse$1Y4BNt@1Y4BOVC401+1Y4BOS:y!@(Nu3m01+(Nt:symbol'✠'@[w9g01+:x=324:y=112",
            "*lww#mouse$1Y4BNq@1Y4BNw9g01+1Y4BNt:y!@[r2i02+[q:symbol'✪'",
            "*lww#mouse$1Y4BN@1Y4BNr2i02+1Y4BNq:symbol!@[bCc01+['✢'@[oDg01+:x=319:y=129",
            "*lww#mouse$1Y4BMf@1Y4BNoDg01+1Y4BN:y!@(Mg3201+(Mf:symbol'✞'@[jEB01+:x=261:y=72",
            "*lww#mouse$1Y4BMW@1Y4BMjEB01+1Y4BMf:y!@[WFp02+[W:symbol'✶'@[aFQ01+:x=278:y=102",
            "*lww#mouse$1Y4BM@1Y4BMaFQ01+1Y4BMW:y!@[4D102+[:symbol'❇'@[93m01+:x=410:y=152",
            "*lww#mouse$1Y4BJo@1Y4BM93m01+1Y4BM:y!@(Jp1a02+(Jo:symbol'✘'@(LQAN01+:x=235:y=115",
            "*lww#mouse$1Y4BJ9@1Y4BLQAN01+1Y4BJo:y!@(JB0501+[9:symbol'❅'@[PDs01+:x=377:y=99",
            "*lww#mouse$1Y4BJ6@1Y4BJPDs01+1Y4BJ9:y!@[73U01+[6:symbol'✦'",
            "*lww#mouse$1Y4BIq@1Y4BJ73U01+1Y4BJ6:symbol!@(Ir8801+(Iq'❂'",
            "*lww#mouse$1Y4BI@1Y4BIr8801+1Y4BIq:symbol!@[46s02+['✥'@[8Al01+:x=295:y=67",
            "*lww#mouse$1Y4BHq@1Y4BI8Al01+1Y4BI:y!@(HqEL01+(Hq:symbol'✥'@(I06j01+:x=466:y=79",
            "*lww#mouse$1Y4BHQ@1Y4BI06j01+1Y4BHq:y!@(HS0802+[Q:symbol'❈'@[n9b01+:x=252:y=101",
            "*lww#mouse$1Y4BH3@1Y4BHn9b01+1Y4BHQ:y!@[41602+[3:symbol'✝'@[B0O01+:x=361:y=96",
            "*lww#mouse$1Y4BGd@1Y4BHB0O01+1Y4BH3:y!@(GdF_01+(Gd:symbol'✭'",
            "*lww#mouse$1Y4BG@1Y4BGdF_01+1Y4BGd:symbol!@[7B801+['✛'@[XFb01+:x=406:y=168",
            "*lww#mouse$1Y44H@1Y4BGXFb01+1Y4BG:y!@1Y44Ha0p01+1Y44H:symbol'✬'",
            "*lww#mouse$1Y44EJ@1Y44Ha0p01+1Y44H:symbol!@(EK4W01+(EJ'❄'",
            "*lww#mouse$1Y44EG@1Y44EK4W01+1Y44EJ:symbol!@[G9j02+[G'✣'",
            "*lww#mouse$1Y44EC@1Y44EG9j02+1Y44EG:symbol!@[D3H01+[C'✭'",
            "*lww#mouse$1Y44E@1Y44ED3H01+1Y44EC:symbol!@[58e01+['❌'",
            "*lww#mouse$1Y44C@1Y44E58e01+1Y44E:symbol!@(CeCT01+(C'✾'",
            "*lww#mouse$1Y4C9@1Y4C9ZEd01+1Y4C9:symbol!@[VF801+'✟'@[ZEd01+:x=195:y=157",
        ])
        
        XCTAssertEqual(ids, [
            "mice",
            "mouse$1Y4C8c",
            "mouse$1Y4C8W",
            "mouse$1Y4C8",
            "mouse$1Y4C7J",
            "mouse$1Y4C7D",
            "mouse$1Y4C7",
            "mouse$1Y4C6M",
            "mouse$1Y4C6",
            "mouse$1Y4C4g",
            "mouse$1Y4C4",
            "mouse$1Y4C2",
            "mouse$1Y4C1",
            "mouse$1Y4Bv",
            "mouse$1Y4Btp",
            "mouse$1Y4BtE",
            "mouse$1Y4Bt",
            "mouse$1Y4Bsu",
            "mouse$1Y4Bs",
            "mouse$1Y4Bk",
            "mouse$1Y4BX",
            "mouse$1Y4BVs",
            "mouse$1Y4BV",
            "mouse$1Y4BU",
            "mouse$1Y4BT",
            "mouse$1Y4BSk",
            "mouse$1Y4BSd",
            "mouse$1Y4BSV",
            "mouse$1Y4BSP",
            "mouse$1Y4BS",
            "mouse$1Y4BR",
            "mouse$1Y4BP",
            "mouse$1Y4BOo",
            "mouse$1Y4BOX",
            "mouse$1Y4BOS",
            "mouse$1Y4BNt",
            "mouse$1Y4BNq",
            "mouse$1Y4BN",
            "mouse$1Y4BMf",
            "mouse$1Y4BMW",
            "mouse$1Y4BM",
            "mouse$1Y4BJo",
            "mouse$1Y4BJ9",
            "mouse$1Y4BJ6",
            "mouse$1Y4BIq",
            "mouse$1Y4BI",
            "mouse$1Y4BHq",
            "mouse$1Y4BHQ",
            "mouse$1Y4BH3",
            "mouse$1Y4BGd",
            "mouse$1Y4BG",
            "mouse$1Y44H",
            "mouse$1Y44EJ",
            "mouse$1Y44EG",
            "mouse$1Y44EC",
            "mouse$1Y44E",
            "mouse$1Y44C",
            "mouse$1Y4C9",
        ])
    }
    
    func testBatchSplitById2() {
        let b = Batch.splitById(source:
            "*set#mice@1Y4EG3U001+1Y4EG!@>mouse$1Y4EG@(FOGS01(FO>mouse$1Y4EFO@[19001[>mouse$1Y4EF@(ESL001(E>mouse$1Y4EE@(DmFb01(Dm>mouse$1Y4EDm@[14_01[>mouse$1Y4ED@1Y4CajDZ01+1Y4Caj>mouse$1Y4Caj@(9GS001(9>mouse$1Y4C9@(8c5d01(8c>mouse$1Y4C8c@[W7D01[W>mouse$1Y4C8W@[OJ001[>mouse$1Y4C8@(7J5v01(7J>mouse$1Y4C7J@[D5x01[D>mouse$1Y4C7D@[8O001[>mouse$1Y4C7@(6MAd01(6M>mouse$1Y4C6M@[CH001[>mouse$1Y4C6@(4gRD01(4g>mouse$1Y4C4g@[f1101[>mouse$1Y4C4@(2A0Q01(2>mouse$1Y4C2@(1S7b01(1>mouse$1Y4C1@1Y4BvT4x01+1Y4Bv>mouse$1Y4Bv@(tpAI01(tp>mouse$1Y4Btp@[EFP01[E>mouse$1Y4BtE@[2Bq01[>mouse$1Y4Bt@(svAs01(su>mouse$1Y4Bsu@[T3s01[>mouse$1Y4Bs@(koCv01(k>mouse$1Y4Bk@(Xj3g01(X>mouse$1Y4BX@(Vt8q01(Vs>mouse$1Y4BVs@[AA101[>mouse$1Y4BV@(UFEC01(U>mouse$1Y4BU@(TR6301(T>mouse$1Y4BT@(SkCP01(Sk>mouse$1Y4BSk@[dCI01[d>mouse$1Y4BSd@[W0x01[V>mouse$1Y4BSV@[PB501[P>mouse$1Y4BSP@[9G001[>mouse$1Y4BS@(Rp8r01(R>mouse$1Y4BR@(PfDI01(P>mouse$1Y4BP@(Op7S01(Oo>mouse$1Y4BOo@[Y7v01[X>mouse$1Y4BOX@[T4F01[S>mouse$1Y4BOS@(Nu3l01(Nt>mouse$1Y4BNt@[r2i01[q>mouse$1Y4BNq@[S7O01[>mouse$1Y4BN@(Mg3101(Mf>mouse$1Y4BMf@[WFp01[W>mouse$1Y4BMW@[4D101[>mouse$1Y4BM@(Jp1a01(Jo>mouse$1Y4BJo@[B0401[9>mouse$1Y4BJ9@[73T01[6>mouse$1Y4BJ6@(Ir8701(Iq>mouse$1Y4BIq@[46s01[>mouse$1Y4BI@(HqEK01(Hq>mouse$1Y4BHq@[S0801[Q>mouse$1Y4BHQ@[41601[3>mouse$1Y4BH3@(GdFZ01(Gd>mouse$1Y4BGd@[7B701[>mouse$1Y4BG@1Y44Ha0o01+1Y44H>mouse$1Y44H@(EK4V01(EJ>mouse$1Y44EJ@[G9j01[G>mouse$1Y44EG@[D3G01[C>mouse$1Y44EC@[58d01[>mouse$1Y44E@(CeCS01(C>mouse$1Y44C"
          )
        XCTAssertEqual(b.count, 1)
        
        let (_, ids): ([String], [String]) =
            b.reduce(into: ([], [])) { arrs, f in
                arrs.0.append(f.toString())
                arrs.1.append(f.id.toString())
            }

        XCTAssertEqual(ids, ["mice"])
    }
    
    func testGrammar() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        let uuid = grammar.uuid.tester
        XCTAssert(uuid.test("0"))
        XCTAssert(uuid.test("$name"))
        XCTAssert(uuid.test("time-origin"))
        XCTAssert(uuid.test("-origin"))
        XCTAssert(uuid.test(""))
        XCTAssertFalse(uuid.test("--"))
        
        let atom = grammar.atom.tester
        XCTAssert(atom.test("=1"))
        XCTAssertFalse(atom.test("=1="))
        XCTAssertFalse(atom.test("'''"))
        XCTAssert(atom.test(#"'\''"#))
        XCTAssert(atom.test(#"'\\\''"#))
        XCTAssertFalse(atom.test(#"'\\\'"#))
        XCTAssert(atom.test(#"'\u000a'"#))
        
        XCTAssert(atom.test(#"'"single-quoted \'"'"#))
        XCTAssert(atom.test(#"'{"json":"not terrible"}'"#))
        
        XCTAssert(atom.test("^3.1415"))
        XCTAssert(atom.test("^.1"))
        XCTAssert(atom.test("^1.0e6"))
        XCTAssertFalse(atom.test("^1e6")) // mandatory .
        XCTAssertFalse(atom.test("^1"))
        XCTAssert(atom.test("^0.0"))
        
        XCTAssert(atom.test(">true"))
        XCTAssert(atom.test(">false"))
        
        let frame = grammar.frame.tester
        XCTAssert(frame.test("*lww#`@`:`>end"))
        XCTAssert(frame.test("#$name?"))
        XCTAssert(frame.test("*lww#time-orig@`:key=1"))
        XCTAssert(frame.test("*lww#name@time-orig!:key=1:string'str'"))
        
        XCTAssert(frame.test("*lww#test@time-orig:ref>>another."))
        XCTAssert(frame.test("*lww#test@time-orig!:A=1,:B'2':C>3."))
    }
    
    func testUuid() {
        let simple = Uuid.fromString("time-orig")
        XCTAssertEqual(simple.value, "time")
        XCTAssertEqual(simple.origin, "orig")
        XCTAssertEqual(simple.sep, "-")
        
        let simple1 = Uuid.fromString("time1-orig")
        XCTAssertGreaterThanOrEqual(simple1, simple)
        XCTAssertNotEqual(simple1, simple)
        XCTAssertEqual(simple1.toString(), "time1-orig")
        XCTAssertEqual(simple1.toString(ctx: simple), "(1")
        XCTAssertEqual(Uuid.fromString("newtime-orig").toString(ctx: simple), "newtime-")
        XCTAssert(simple.isTime)
        XCTAssert(simple.isEvent)
        
        let lww = Uuid.fromString("lww")
        XCTAssertEqual(lww.sep, "$")
        XCTAssertEqual(lww.value, "lww")
        XCTAssertEqual(lww.origin, "0")
        XCTAssertNotEqual(lww, .fromString("lww-0"))
        XCTAssertEqual(lww.toString(), "lww")
        XCTAssert(lww.isName)
        XCTAssertFalse(lww.isTime)
        
        let hash = Uuid.fromString("1234567890%abcdefghij")
        XCTAssert(hash.isHash)
        
        let zero = Uuid.fromString("0")
        XCTAssertEqual(zero.value, "0")
        XCTAssertEqual(zero.origin, "0")
        XCTAssertEqual(zero.sep, "-")
        XCTAssertEqual(zero.toString(ctx: .error), "0")
        XCTAssertEqual(zero.toString(ctx: .zero), "0")
        
        let varname = Uuid.fromString("$varname")
        XCTAssertEqual(varname.toString(), "$varname")
        XCTAssertEqual(varname.origin, "varname")
        XCTAssert(varname.isZero)
        XCTAssertEqual(varname.toString(ctx: simple), "0$varname")
        
        let nice_str = Uuid.fromString("1", ctx: simple)
        XCTAssertEqual(nice_str.value, "1")
        XCTAssertEqual(nice_str.origin, "0")
        XCTAssertEqual(nice_str.sep, "$")
        XCTAssertEqual(nice_str.toString(), "1")
        XCTAssertEqual(nice_str.toString(ctx: simple), "1")
        
        // no prefix compression for meaningful string constants
        let str1 = Uuid.fromString("long1$")
        let str2 = Uuid.fromString("long2$")
        XCTAssertEqual(str1.toString(ctx: str2), "long1")
        
        let lww1 = Uuid.fromString("lww", ctx: simple1)
        XCTAssertEqual(lww1.value, "lww")
        XCTAssertEqual(lww1.sep, "$")
        XCTAssertEqual(lww1.origin, "0")
        let lww2 = Uuid.fromString("lww", ctx: str1)
        XCTAssertEqual(lww2.value, "lww")
        XCTAssertEqual(lww2.sep, "$")
        XCTAssertEqual(lww2.origin, "0")
        
        let clone = Uuid.fromString("", ctx: .fromString("$A"))
        XCTAssertEqual(clone.toString() + "", "$A")
        
        var vec = Vector()
        let uuids = ["time-origin",
                     "time01-origin",
                     "time2-origin2"]
            .map { Uuid.fromString($0) }
        vec.append(uuids[0])
        vec.append(uuids[1])
        vec.append(uuids[2])
        XCTAssertEqual(vec.toString(), "time-origin,[1,(2-{2")
        XCTAssertEqual(Array(vec), uuids)
        
        var zeros = Vector.Iter(body: ",,,")
        XCTAssert(zeros.uuid.map(\.isZero) ?? false)
        zeros.nextUuid()
        XCTAssert(zeros.uuid.map(\.isZero) ?? false)
        zeros.nextUuid()
        XCTAssert(zeros.uuid.map(\.isZero) ?? false)
        zeros.nextUuid()
        XCTAssert(zeros.uuid == nil);
        
        let num = Uuid.base2int(base: "0000000011");
        XCTAssertEqual(num, 65)
    }
}

extension NSRegularExpression {
    func test(_ text: String) -> Bool {
        firstMatch(in: text,
                   range: .init(location: 0,
                                length: text.utf16.count)) != nil
    }
    
    var tester: Self {
        try! Self(pattern: "^(?:\(pattern))$")
    }
}
